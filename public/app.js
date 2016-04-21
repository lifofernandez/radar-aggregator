var App = angular.module('App', []);

App.controller('EntriesCtrl', function($scope, $http) {
	
	var search = window.location.search;
	var entriesJson = 'hoy.json';
	if(search) {
		search = search.replace('?','');
	 	entriesJson = search+'.json';
		//console.log(search) 
	}


    $http.get(entriesJson)
        .then(function successCallback(res) {

            angular.forEach(res, function(value, key) {
                //console.log(res.data);
            });
            $scope.entries = res.data.entries;

        }, function errorCallback(response) {
        	document.body.innerHTML = 'no hay nada para > '+ search;

        	//console.log('error');
	    	// called asynchronously if an error occurs
	    	// or server returns response with an error status.

	  	});
});
 