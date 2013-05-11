# Basic tree class
#
class Model.Tree
	# Constructor for tree
	#
	# @param [Node] root The root node of the tree
	#
	constructor: ( root = new Model.Node( null, null ) ) -> 
		@_root = root
		@_current = @_root
	
	# Add an object to the tree
	#
	# @param object [Object]  The object to add to the tree
	# @param parent [Node] The future parent
	# @return [Node] the added node
	#
	add: ( object, parent = @_current ) ->
		node = new Model.Node(object, parent)
		@_current = node
		if parent isnt null
			parent._branch = node
		return node
	
	# Add a node to the tree
	#
	# @param node [Model.Node] The node to add.
	# @param parent [Model.Node] The new parent of the node.
	#
	addNode: ( node, parent = @_current ) ->
		node._parent = parent
		parent._branch = node
		parent._children.push node
		@_current = node
		return node
	
	# Find an objects location in the tree
	#
	# @param [Object] object The object to find
	# @param [Node] start The node to start searching from. Default is root
	# @return [Node] The node containing the object or null if it doesn't exist.
	#
	find: ( object, start = @_root ) ->
		return start if object is start._object
		for child in start._children
			res = @find( object, child)
			return res if res
		return null
	
	iterator: ( ) ->
		return @breadthfirst()
	
	breadthfirst: ( start = @_root ) ->
		res = [start]

		res.push start._children...

		for child in start._children
			arr = @breadthfirst(child)
			arr.splice(0,1)
			res.push arr...

		return res
	
	depthfirst: ( start = @_root ) ->
		res = [start]

		for child in start._children
			res.push @depthfirst(child)...

		return res
		
		
(exports ? this).Model.Tree = Model.Tree
