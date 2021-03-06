_ = lodash

angular.module('app').controller 'calendarCtrl', ['$scope', '$meteor', '$window', '$filter', ($scope, $meteor, $window, $filter) ->
	yesterday = new Date()
	yesterday.setDate(yesterday.getDate()-1)
	$scope.events = $scope.$meteorCollection () -> share.Events.find { start: {$gte: yesterday} }
	$scope.settings = $scope.$meteorObject share.Settings, {}

	$scope.colorStyle = (colorOrEvent) ->
		if typeof(colorOrEvent) != 'string' 
			eventType = _.find $scope.settings.eventTypes, (et) -> et.key == colorOrEvent.type
			color = eventType.color
		else
			color = colorOrEvent

		if tinycolor(color).isLight()
			readableColor = '#000000'
		else
			readableColor = '#ffffff'
		# colors = tinycolor(color).splitcomplement()
		# someColors = colors.map (t) -> t.toHexString()
		# mostReadable = tinycolor.mostReadable(color, someColors, {includeFallbackColors: true, level: "AA", size: "small"})
		# readableColor = mostReadable?.toHexString() || '#fff'
		#console.log "readableColor: #{color} => #{readableColor} (#{mostReadable})"
		{ "color": readableColor, "background-color": color}

	$scope.setEditEvent = () ->
		newTimeFrom = new Date()
		newTimeFrom.setMinutes(0)
		newTimeTo = new Date()
		newTimeTo.setHours(newTimeFrom.getHours() + 1)
		newTimeTo.setMinutes(0)

		$scope.editEvent =
			title: ''
			start: newTimeFrom
			end: newTimeTo
			type: $scope.settings.eventTypes?[0].key
		#console.log $scope.editEvent

	# startup functions
	$scope.setEditEvent()
	$meteor.requireValidUser (user) ->
		userIsAdmin = user?.profile?.isAdmin || false
		onlyAdmin = $scope.settings.onlyAdminCanEditEvents
		$scope.canEditEvents = !onlyAdmin || userIsAdmin
		console.log "user #{user.username} is admin: #{userIsAdmin} and onlyAdminCanEditEvents=#{onlyAdmin}"

	# stuff for calendar
	$scope.eventSources	= []
	for et in $scope.settings.eventTypes
		style = $scope.colorStyle(et.color)
		readableColor = style["color"]
		$scope.eventSources.push
			textColor: readableColor
			color: et.color
			events: $scope.$meteorCollection () -> share.Events.find {type: et.key}

	$scope.calendarConfig =
		calendar:
			weekNumbers: true
			dayNames: ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"]
			dayNamesShort: ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]
			monthNames: ["Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember"]
			monthNamesShort: ["Jan","Feb","Mär","Apr","Mai","Jun","Jul","Aug","Sep","Okt","Nov","Dez"]
			buttonText:
				today:    'Heute'
				month:    'Monat'
				week:     'Woche'
				day:      'Tag'
			firstDay: 1
			height: 500
			editable: false
			timeFormat: 'H(:mm)'
			header:
				left: 'title'
				center: ''
				right: 'today prev,next'

	$scope.format = 'dd.MM.yyyy'
	$scope.status = 
		openedFrom: false
		openedTo: false

	$scope.dateOptions =
		formatYear: 'yy'
		startingDay: 1

	$scope.openFrom = ($event) ->
		$event.preventDefault()
		$event.stopPropagation()
		$scope.status.openedFrom = true

	$scope.openTo = ($event) ->
		$event.preventDefault()
		$event.stopPropagation()
		$scope.status.openedTo = true

	$scope.bgColorStyle = (eventTypeKey) ->
		eventType = _.find $scope.settings.eventTypes, (et) -> et.key == eventTypeKey
		{"background-color": eventType.color}

	$scope.eventDateString = (event) ->
		fd = $filter('date')
		if event.end && event.end != event.start
			if event.start.getMonth() == event.end.getMonth() && event.start.getDate() == event.end.getDate()
				es = fd(event.start, "dd.MM.yy HH:mm")
				ee = fd(event.end, "HH:mm")
				"#{es} - #{ee}"
			else
				es = fd(event.start, "dd.MM.yy HH:mm")
				ee = fd(event.end, "dd.MM.yy HH:mm")
				"#{es} - #{ee}"
		else
			fd(event.start, "dd.MM.yy HH:mm")

	$scope.editExistingEvent = (event) ->
		$scope.editEvent = event

	$scope.deleteEvent = (event) ->
		console.log "remove event: #{event.title}"
		$scope.$meteorCollection(share.Events).remove event

	$scope.saveEvent = (newDateToEntered) ->
		#console.log "create new event: #{newTitle}, #{newDateFrom} #{newTimeFrom} - #{newDateTo} #{newTimeTo}, #{newEventType}"
		if !newDateToEntered
			$scope.editEvent.end = null
		if !$scope.editEvent._id
			$scope.$meteorCollection(share.Events).save($scope.editEvent).then (inserts) ->
				i = _.first(inserts)
				console.log "inserted new event with id: #{i._id}"
				$scope.setEditEvent()
		else
			$scope.setEditEvent()
]
