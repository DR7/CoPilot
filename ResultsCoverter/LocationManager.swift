import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locationText: String = ""
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func start() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            locationText = "Location services are not enabled."
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    self.locationText = "Error retrieving location: \(error.localizedDescription)"
                } else if let placemark = placemarks?.first {
                    self.locationText = """
                    Latitude: \(location.coordinate.latitude)
                    Longitude: \(location.coordinate.longitude)
                    Address: \(placemark.postalAddressFormatted)
                    """
                    self.locationManager.stopUpdatingLocation()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationText = "Failed to retrieve location: \(error.localizedDescription)"
    }
}

extension CLPlacemark {
    var postalAddressFormatted: String {
        var address = ""
        if let subThoroughfare = subThoroughfare { address += subThoroughfare + " " }
        if let thoroughfare = thoroughfare { address += thoroughfare + ", " }
        if let locality = locality { address += locality + ", " }
        if let administrativeArea = administrativeArea { address += administrativeArea + " " }
        if let postalCode = postalCode { address += postalCode + ", " }
        if let country = country { address += country }
        return address
    }
}
