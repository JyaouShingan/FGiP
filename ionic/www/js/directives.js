angular.module('fish.directives', [])

.directive('map', function() {
  return {
    restrict: 'E',
    scope: {
      onCreate: '&'
    },
    link: function ($scope, $element, $attr) {
      function initialize() {
        var mapOptions = {
          center: new google.maps.LatLng(44.987469, -65.815574),
          zoom: 10,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        var map = new google.maps.Map($element[0], mapOptions);

        $scope.onCreate({map: map});

        // Stop the side bar from dragging when mousedown/tapdown on the map
        google.maps.event.addDomListener($element[0], 'mousedown', function (e) {
          e.preventDefault();
          return false;
        });

        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://ec2-54-152-143-50.compute-1.amazonaws.com:4000/queryLocation");
        xhr.responseType = "text";
        var received;
        var parsed;
        xhr.onload = function()
        {
          received = xhr.response;
          parsed = JSON.parse(received);
          // console.log(JSON.stringify(parsed.data[0]))
          for(var i = 0; i < parsed.data.length; i++){
            var id = parsed.data[i]._id;
            var position = new Object();
            position.lat = parsed.data[i].latitude;
            position.lng = parsed.data[i].longitude;
            var username = parsed.data[i].username;
            var pos = new google.maps.LatLng(position.lat, position.lng);
            loadMarkers(pos,id);
          }
          // console.log(received)
        }
        xhr.send();

        //mark current location
        navigator.geolocation.getCurrentPosition(function (pos) {
          console.log('Got pos', pos);
          var currPos =  new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude)
          var marker = new google.maps.Marker({
              position: currPos,
              animation: google.maps.Animation.DROP,
              map: map,
              icon: "http://www.mobilabs.com/images/help/help-gps-icon.png"
          });
        }, function (error) {
          alert('Unable to get location: ' + error.message);
        });

        //load markers from db
        function loadMarkers(position,id){
          $scope.lat = position.lat();
          $scope.lng = position.lng();
          // console.log($scope.lat)
          // console.log($scope.lng)
          // marker.setMap(null);//test
          google.maps.event.addListenerOnce(map, 'idle', function(){
          var marker = new google.maps.Marker({
              position: position,
              animation: google.maps.Animation.DROP,
              map: map,
              icon: "http://i.imgur.com/HzPa48c.png"
          });
          var infoWindow = new google.maps.InfoWindow({
              content: id
          });

          google.maps.event.addListener(marker, 'click', function () {
              infoWindow.open(map, marker);
          });

        });
        }


      }

      if (document.readyState === "complete") {
        initialize();

      } else {
        google.maps.event.addDomListener(window, 'load', initialize);
      }
    }
  }
});
