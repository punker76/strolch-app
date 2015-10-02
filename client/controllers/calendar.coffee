angular.module('app').controller 'calendarCtrl', ['$scope', '$meteor', '$window', ($scope, $meteor, $window) ->
	$scope.newEventType = 'CLOSED'
	$scope.events = $scope.$meteorCollection () -> share.Events.find()
	$scope.settings = $scope.$meteorObject share.Settings, {}

	$meteor.requireValidUser (user) ->
		userIsAdmin = user?.profile?.isAdmin || false
		onlyAdmin = $scope.settings.onlyAdminCanEditEvents
		$scope.canEditEvents = !onlyAdmin || userIsAdmin
		console.log "user #{user.username} is admin: #{userIsAdmin} and onlyAdminCanEditEvents=#{onlyAdmin}"

	# stuff for calendar
	closedEvents = 
		textColor: '#fff'
		color: '#D46A6A'
		events: $scope.$meteorCollection () -> share.Events.find {type: 'CLOSED'}
	eventEvents = 
		textColor: '#fff'
		color: '#A5C663'
		events: $scope.$meteorCollection () -> share.Events.find {type: 'EVENT'}
	jubiEvents = 
		textColor: '#fff'
		color: '#699'
		events: $scope.$meteorCollection () -> share.Events.find {type: 'JUBI'}

	$scope.eventSources = [closedEvents, eventEvents, jubiEvents]
	$scope.calendarConfig =
		calendar:
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

	# stuff for datepicker
	$scope.newDateFrom = new Date()
	$scope.newDateTo = new Date()
	$scope.newTimeFrom = new Date()
	$scope.newTimeTo = new Date()
	$scope.format = 'dd.MM.yyyy'
	$scope.openedFrom = false
	$scope.openedTo = false

	$scope.dateOptions =
		formatYear: 'yy'
		startingDay: 1

	$scope.openFrom = ($event) ->
		$event.preventDefault()
		$event.stopPropagation()
		$scope.openedFrom = true
	$scope.openTo = ($event) ->
		$event.preventDefault()
		$event.stopPropagation()
		$scope.openedTo = true

	$scope.deleteEvent = (event) ->
		console.log "remove event: #{event.title}"
		$scope.$meteorCollection(share.Events).remove event

	$scope.addEvent = () ->
		e = 
			title: $scope.newTitle
			start: new Date $scope.newDateFrom.getFullYear(), $scope.newDateFrom.getMonth(), $scope.newDateFrom.getDate(), $scope.newTimeFrom.getHours(), $scope.newTimeFrom.getMinutes()
			end: new Date $scope.newDateTo.getFullYear(), $scope.newDateTo.getMonth(), $scope.newDateTo.getDate(), $scope.newTimeTo.getHours(), $scope.newTimeTo.getMinutes()
			type: $scope.newEventType 
		console.log e
		$scope.$meteorCollection(share.Events).save(e).then (inserts) ->
			e = _.first(inserts)
			console.log "inserted new event with id: #{e._id}"
]
