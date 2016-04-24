angular.module('fish.controllers', [])

.controller('MapCtrl', function($scope, $ionicLoading) {
  $scope.mapCreated = function(map) {
    $scope.map = map;
  };

  $scope.addTrap = function(){
    console.log("add trap location on current location")
    navigator.geolocation.getCurrentPosition(function (pos) {
      var currPos =  new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude)
      // console.log(currPos.lat())

      var xhr = new XMLHttpRequest();   // new HttpRequest instance
      xhr.open("PUT", "http://ec2-54-152-143-50.compute-1.amazonaws.com:4000/update");
      xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
      var randID = "0x"+(Math.random()*0xFFFF<<0).toString(16);
      // console.log(randID);
      xhr.send(JSON.stringify({id: randID, longitude: currPos.lng(), latitude: currPos.lat(), updateTime : "1461481987.233078", modified : false, username:"CKY"}));

    }, function (error) {
      alert('Unable to get location: ' + error.message);
    });
  }

  $scope.centerOnMe = function () {
    console.log("Centering");
    if (!$scope.map) {
      return;
    }



    $scope.loading = $ionicLoading.show({
      content: 'Getting current location...',
      showBackdrop: false
    });

    navigator.geolocation.getCurrentPosition(function (pos) {
      console.log('Got pos', pos);
      $scope.map.setCenter(new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude));
      $scope.loading.hide();

    }, function (error) {
      alert('Unable to get location: ' + error.message);
    });
  };
});
