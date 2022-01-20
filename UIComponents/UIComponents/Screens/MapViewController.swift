//
//  MapViewController.swift
//  UIComponents
//
//  Created by Semih Emre ÜNLÜ on 9.01.2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var index = 0 {
        didSet{
            mapView.setNeedsDisplay()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkLocationPermission()
        addLongGestureRecognizer()
    }

    private var currentCoordinate: CLLocationCoordinate2D?
    private var destinationCoordinate: CLLocationCoordinate2D?

    func addLongGestureRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleLongPressGesture(_ :)))
        self.view.addGestureRecognizer(longPressGesture)
    }

    @objc func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        destinationCoordinate = coordinate

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Pinned"
        mapView.addAnnotation(annotation)
    }

    func checkLocationPermission() {
        switch self.locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            locationManager.requestLocation()
        case .denied, .restricted:
            //popup gosterecegiz. go to settings butonuna basildiginda
            //kullaniciyi uygulamamizin settings sayfasina gonder
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError()
        }
    }

    @IBAction func showCurrentLocationTapped(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    //MARK: Reset routes for another pin
    func resetRoutes(){
        mapView.removeOverlays(mapView.overlays)
        
    }

    
    //MARK: Drawing root
    @IBAction func drawRouteButtonTapped(_ sender: UIButton) {
        resetRoutes()
        guard let currentCoordinate = currentCoordinate,
              let destinationCoordinate = destinationCoordinate else {
                  // log
                  // alert
            return
        }

        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let source = MKMapItem(placemark: sourcePlacemark)

        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        let destination = MKMapItem(placemark: destinationPlacemark)

        let directionRequest = MKDirections.Request()
        directionRequest.source = source
        directionRequest.destination = destination
        directionRequest.transportType = .automobile
        directionRequest.requestsAlternateRoutes = true

        let direction = MKDirections(request: directionRequest)
        
        direction.calculate { response, error in
            guard error == nil else {
                //log error
                //show error
                print(error?.localizedDescription)
                return
            }

           // guard let polyline: MKPolyline = response?.routes.first?.polyline else { return }
            guard let routes: [MKRoute] = response?.routes else { return }
            var polylines = [MKPolyline]()
            var i = 0
            for route in routes{
                route.polyline.title = "\(i)"
                i += 1
                polylines.append(route.polyline)
            }
            
            //self.mapView.addOverlay(polyline, level: .aboveLabels)
         
            self.mapView.addOverlays(polylines, level: .aboveLabels)
            
            let rect = polylines[self.index].boundingMapRect
            let region = MKCoordinateRegion(rect)
            self.mapView.setRegion(region, animated: true)
            //Odev 1 navigate buttonlari ile diger route'lar gosterilmelidir.
        }
    }
    
    @IBAction func switchButtonTapped(_ sender: UIBarButtonItem) {
        print(index)
        switch sender.tag{
        case 1:
            if index >= 0 && index < 2{
                index += 1
            } else if index == 2{
                index = 0
            }
        case 2:
            if index == 0{
                index = 2
            } else if index > 0 && index <= 2{
                index -= 1
            }
        default:
            return
        }
        
    }
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        currentCoordinate = coordinate
        print("latitude: \(coordinate.latitude)")
        print("longitude: \(coordinate.longitude)")
        mapView.setCenter(coordinate, animated: true)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermission()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        /*
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .blue.withAlphaComponent(0.7)
        renderer.lineWidth = 7
        return renderer
        */
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        print(polyline.title)
        
        if polyline.title == "\(index)"{
            renderer.strokeColor = UIColor.blue
        }else{
            renderer.strokeColor = UIColor.darkGray
            }
        return renderer
        }
    
}
