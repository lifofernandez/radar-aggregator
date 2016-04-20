var App = angular.module('App', []);

App.controller('EntriesCtrl', function($scope, $http) {

	$entriesJson = 'hoy.json';

    $http.get($entriesJson)
        .then(function(res) {
            angular.forEach(res, function(value, key) {
                //console.log(res.data);
            });
            $scope.entries = res.data.entries;
        });

});


