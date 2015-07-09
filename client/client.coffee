# meteor accounts config
Accounts.ui.config
  passwordSignupFields: 'USERNAME_ONLY'

# angular
app = angular.module 'app', ['angular-meteor', 'ui.router', 'ngTagsInput']

# routes
userResolve = 
				"currentUser": [
					"$meteor", ($meteor) ->
						$meteor.requireUser()
				]

app.config ['$stateProvider', '$urlRouterProvider', '$locationProvider', ($stateProvider, $urlRouterProvider, $locationProvider) ->
	$stateProvider
		.state 'alle',
			url: '/'
			templateUrl: 'client/jade/alle.html'
			controller: 'alleCtrl'
			resolve: userResolve
		.state 'archived',
			url: '/archived'
			templateUrl: 'client/jade/alle.html'
			controller: 'archivedCtrl'
			resolve: userResolve
		.state 'neu',
			url: '/neu'
			templateUrl: 'client/jade/eine.html'
			controller: 'neuCtrl'
			resolve: userResolve
		.state 'eine',
			url: '/eine/:id'
			templateUrl: 'client/jade/eine.html'
			controller: 'eineCtrl'
			resolve: userResolve
		.state 'tags',
			url: '/tags'
			templateUrl: 'client/jade/tags.html'
			controller: 'tagsCtrl'
			resolve: userResolve
		.state 'login',
			url: '/login'
			templateUrl: 'client/jade/login.html'
			
	$urlRouterProvider.otherwise '/'
	$locationProvider.html5Mode true
]

app.run ['$rootScope', '$state', ($rootScope, $state) ->
	Accounts.onLogin () -> $state.go 'alle'
	accountsUIBootstrap3.logoutCallback = () -> $state.go 'login'
	$rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams, error) ->
		# We can catch the error thrown when the $requireUser promise is rejected
		# and redirect the user back to the main page
		if error == 'AUTH_REQUIRED'
			$state.go 'login'
]

# fix tags 
fixtags = (whos, tags, changetag) ->
	fixed = false
	for t in tags
		if t._id == changetag._id
			oldname = t.name
			t.name = changetag.name
			console.log "tagupdate from #{oldname} to #{changetag.name} of #{whos}"
			fixed = true
	fixed

app.run ['$meteor', ($meteor) ->
	share.Tags.after.update (userId, tag) ->
		families = $meteor.collection(share.Families)
		console.log "updated tag"
		for f in families
			fixed = false
			if f.mama and f.mama.tags
				fixed |= fixtags "#{f.mama.vorname} #{f.mama.nachname}", f.mama.tags, tag
			if f.papa and f.papa.tags
				fixed |= fixtags "#{f.papa.vorname} #{f.papa.nachname}", f.papa.tags, tag
			for k in f.kinder
				if k and k.tags
					fixed |= fixtags "#{k.vorname} #{k.nachname}", k.tags, tag
			if fixed
				console.log f

		$meteor.collection(share.Families).save()
]

app.controller 'neuCtrl', ['$scope', '$meteor', ($scope, $meteor) ->
	$scope.isNew = true
	$scope.family = {}
	$scope.save = () ->
		$meteor.collection(share.Families).save $scope.family
]

app.controller 'alleCtrl', ['$scope', '$meteor', '$window', ($scope, $meteor, $window) ->
	$scope.sortType = 'mama.nachname'
	$scope.showArchived = false
	$scope.families = $meteor.collection(share.Families)
	$scope.deleteFamily = (family) ->
		if $window.confirm 'Wirklich archivieren?'
			console.log "archive id: #{family._id}"
			family.archived = true
]

app.controller 'archivedCtrl', ['$scope', '$meteor', '$window', ($scope, $meteor, $window) ->
	$scope.sortType = 'mama.nachname'
	$scope.showArchived = true
	$scope.families = $meteor.collection(share.Families)
	$scope.undeleteFamily = (family) ->
		if $window.confirm 'Wirklich wiederherstellen?'
			console.log "unarchive id: #{family._id}"
			family.archived = false
]

app.controller 'tagsCtrl', ['$scope', '$meteor', ($scope, $meteor) ->
	$scope.tags = $meteor.collection(share.Tags)
	$scope.deleteTag = (tag) ->
		console.log "delete id: #{tag._id}"
		$scope.tags.remove tag
	$scope.addTag = (tagName) ->
		$scope.tags.push {name: tagName}
		$scope.newName = null
]

app.controller 'eineCtrl', ['$scope', '$meteor', '$stateParams', ($scope, $meteor, $stateParams) ->
	$scope.family = $meteor.object(share.Families, $stateParams.id)
	$scope.tags = $meteor.collection(share.Tags)
	$scope.loadTags = (query) ->
		# filter
		$scope.tags
]