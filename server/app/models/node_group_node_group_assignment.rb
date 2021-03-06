class NodeGroupNodeGroupAssignment < ActiveRecord::Base

  acts_as_paranoid
  
  belongs_to :parent_group, :foreign_key => 'parent_id', :class_name => 'NodeGroup'
  belongs_to :child_group,  :foreign_key => 'child_id',  :class_name => 'NodeGroup'
  
  validates_presence_of :parent_id, :child_id
  
  def self.default_search_attribute
    'assigned_at'
  end
 
  def before_create 
    self.assigned_at ||= Time.now 
  end
  
  def validate
    # Don't allow loops in the connections, the connection hierarchy
    # should constitute a directed _acyclic_ graph.
    if child_group == parent_group || child_group.all_child_groups.include?(parent_group)
      errors.add :child_id, "new child #{child_group.name} creates a loop in group hierarchy, check that group for connection back to #{parent_group.name}"
    end
  end

  def before_create 
    self.assigned_at ||= Time.now 
  end
  
  def after_validation
    # When a new NGNGA is created we need to walk up the parent tree and add
    # virtual NGNAs to each parent group for every child node of the new
    # NGNGA's child_group
    # This is done as an after_validation rather than an after_save so that,
    # if it fails, the new NGNGA won't be saved.  Thus the user is likely to
    # try again and we get a second chance to fix things.  If this was
    # implemented as after_save the user's NGNGA would get saved and they
    # might not realize this failed, or even if they did wouldn't have a way
    # to retry or fix it.
    add_virtual_assignments_to_parents
  end

  # When an NGNA is deleted we need to walk up the parent tree and remove
  # virtual NGNAs
  def before_destroy
    all_child_nodes = child_group.all_child_nodes
    remove_virtual_assignments_from_parents(all_child_nodes)
  end
  
  def add_virtual_assignments_to_parents
    # We can wimp out of actually walking the tree here and operate on
    # all_parent_groups.  We avoid the explicit tree walking (which is done
    # by all_parent_groups) but might have to check more groups than we
    # would if we actually walked the tree if the child group has another real
    # assignment to a parent node.  If we walked the tree we could stop at
    # that point (as we would know that we inserted virtual
    # assignments above that parent when the NGNGA to that parent was
    # created).  And yes, in the time it took to write this comment I
    # probably could have written the tree walking code.  :)
    all_child_nodes = child_group.all_child_nodes
    logger.debug "child group #{child_group.name} has #{all_child_nodes.size} children"
    [parent_group, *parent_group.all_parent_groups].each do |parent|
      logger.debug "add_virtual_assignments_to_parents processing #{parent.name}"
      all_child_nodes.each do |node|
        logger.debug "Checking for existing NGNA for parent #{parent.name} and node #{node.name}"
        if !NodeGroupNodeAssignment.exists?(:node_group_id => parent.id, :node_id => node.id)
          logger.debug "  No existing NGNA for parent #{parent.name} and node #{node.name}, creating"
          NodeGroupNodeAssignment.create(:node_group_id => parent.id, :node_id => node.id, :virtual_assignment => true)
        end
      end
    end
  end
  
  def remove_virtual_assignments_from_parents(child_nodes_to_remove, deleted_ngnga=self)
    [parent_group, *parent_group.parent_groups].each do |parent|
      # Check if each node has a reason to keep its assignment to this parent
      # node group due to other NGNAs
      local_child_nodes_to_remove = child_nodes_to_remove.dup
      all_child_nodes = parent.all_child_nodes_except_ngnga(deleted_ngnga)
      child_nodes_to_remove.each do |child_node_to_remove|
        if all_child_nodes.include?(child_node_to_remove)
          logger.debug "Excluding #{child_node_to_remove.name} from removal from #{parent.name} due to other NGNAs"
          local_child_nodes_to_remove.delete(child_node_to_remove)
        end
      end
      
      local_child_nodes_to_remove.each do |node|
        ngna = NodeGroupNodeAssignment.find_by_node_group_id_and_node_id(parent.id, node.id)
        if ngna.virtual_assignment?
          logger.debug "Removing NGNA from node #{node.name} to parent #{parent.name}"
          ngna.remove_virtual_assignments_from_parents(local_child_nodes_to_remove, deleted_ngnga)
          ngna.destroy
        end
      end
    end
  end
end
