# The spline view displays pathways between modules
#
class View.Spline extends View.RaphaelBase

	# The spline type
	@Type:
		Processing: 0
		Synthesis: 1
		Consuming: 2

	# Creates a new spline
	# 
	# @param paper [Raphael.Paper] the raphael paper
	# @param parent [View.Cell] the cell view this dummy belongs to
	# @param _cell [Model.Cell] the cell model displayed in the parent
	# @param orig [View.Module] the origin of the spline
	# @param dest [View.Module] the destination of the spline
	# @param interaction [Boolean] whether to add interaction to the splines or not
	# @param type [Integer] the type of the spline
	#
	constructor: ( paper, parent, @_cell, @orig, @dest, @_preview = off, @_interaction = on, @_type = Spline.Type.Processing ) ->
		super paper, parent
		@addInteraction() if @_interaction is on		
		
	# Gets the spline class for this type
	#
	# @return [String] the class
	#
	getSplineClass: ( affix = '' ) ->
		type = switch @_type
			when Spline.Type.Processing
				'metabolite'
			#when Spline.Type.Synthesis
			#	'dna'
			#when Spline.Type.Consume
			#	'consume'
			else
				'none fade hide'
				
		affix = "-#{affix}" if affix isnt ''
		affix = "#{affix}-preview" if @_preview
		return "#{type}-spline#{affix}"

	# Adds interaction to the spline
	#
	addInteraction: ( ) ->

		@_bind( 'view.moving', @, @_onViewMoving )
		@_bind( 'view.moved', @, @_onViewMoved )
		@_bind( 'view.drawn', @, @_onViewDrawn )
		return this

	# Sets the correct color of the spline
	#
	setColor: ( ) ->
		if @orig.type is 'Metabolite'
			@color = @orig.color
		else if @dest.type is 'Metabolite'
			@color = @dest.color

		@_contents?.attr('stroke', @color)
		return this

	# Draws the spline
	#
	draw: ( ) ->
		@clear()
		
		path = @_getPathString()
		@_contents = @paper.set()

		@_spline = @paper.path path
		$( @_spline.node ).addClass "#{ @getSplineClass() }"
		@_contents.push @_spline

		if @_interaction and not @_preview
			@_splineDots = @_paper.path path
			$( @_splineDots.node ).addClass "#{ @getSplineClass 'dots' }"
			@_contents.push @_splineDots

		@_contents.insertBefore @paper.bottom
		@setColor()

	# Returns an svg path string from orig to dest
	#
	# @param origOffsetX [float] an offset to be applied on the origin's x coordinate
	# @param origOffsetY [float] an offset to be applied on the origin's y coordinate
	# @param destOffsetX [float] an offset to be applied on the destination's x coordinate
	# @param destOffsetY [float] an offset to be applied on the destination's y coordinate
	# @return [String] a string representing the path
	#
	_getPathString: ( origOffsetX = 0, origOffsetY = 0, destOffsetX = 0, destOffsetY = 0 ) ->
	
		switch @_type
			when Spline.Type.Processing
				if @orig.type is 'Metabolite'
					op = View.Module.Location.Center
					dp = View.Module.Location.Left
				else if @dest.type is 'Metabolite'
					op = View.Module.Location.Right
					dp = View.Module.Location.Center
			when Spline.Type.Synthesis
				op = View.Module.Location.Center
				dp = View.Module.Location.Top
			else
				op = View.Module.Location.Center
				dp = View.Module.Location.Center

		[origX, origY] = @orig.getPoint op
		[destX, destY] = @dest.getPoint dp

		origX += origOffsetX
		origY += origOffsetY
		destX += destOffsetX
		destY += destOffsetY

		dx = Math.abs(destX - origX)
		dy = destY - origY

		x1 = origX + 2/3 * dx + 20
		y1 = origY + 1/4 * dy
		
		x2 = destX - 2/3 * dx - 20 
		y2 = destY - 1/4 * dy

		if @orig.type is 'Metabolite'
			x1 = origX + 1/3 * dx
			y1 = origY + 1/3 * dy

		else if @dest.type is 'Metabolite'
			x2 = destX - 1/3 * dx 
			y2 = destY - 1/3 * dy


		#else 
		

		return "m#{origX},#{origY}C#{x1},#{y1} #{x2},#{y2} #{destX},#{destY}"

	# Gets called when a view is about to move (animated)
	#
	# @param view [Raphael] the view will be moving
	# @param dx [float] the amount to move in the x direction
	# @param dy [float] the amount to move in the y direction
	# @param dt [float] the amount of milliseconds for which to animate
	# @param ease [String] the easing transition being used
	#
	_onViewMoving: ( view, dx, dy, dt, ease ) =>		
		if view is @orig
			path = @_getPathString(dx, dy, 0, 0)
		else if view is @dest
			path = @_getPathString(0, 0, dx, dy)

		if path?
			@_contents?.stop()
			@_contents?.animate
				path: path
			, dt, ease

	# Gets called when a view has moved
	#
	# @param view [Raphael] the view which has moved
	#
	_onViewMoved: ( view ) =>
		if view is @orig or view is @dest
			@draw()

	# Gets called when a view view was drawn
	#
	# @param view [Raphael] the view that was drawn
	#
	_onViewDrawn: ( view ) =>
		if view is @orig or view is @dest
			@draw()
