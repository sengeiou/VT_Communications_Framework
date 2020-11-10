///**
/**



Created by: Wayne Thornton on 11/10/20
Portions Copyright © 2020 to Present ViraTrace LLC. All Rights Reserved.

This file contains Original Code and/or Modifications of Original code as defined in and that are subject to the ViraTrace Public Source License Version 1.0 (the ‘License’). You may not use this file except in compliance with the License. Please obtain of copy of the Licenses at https://github.com/ViraTrace/License and read it before using this file.

The Original Code and all software distributed under the License are distributed on an ‘AS IS’ basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND VIRATRACE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.

*/

import Foundation
import UIKit

/// Sensor array for combining multiple detection and tracking methods.
public class SensorArray : NSObject, Sensor {
    private let logger = ConcreteSensorLogger(subsystem: "Sensor", category: "SensorArray")
    private var sensorArray: [Sensor] = []
    public let payloadData: PayloadData
    public static let deviceDescription = "\(UIDevice.current.name) (iOS \(UIDevice.current.systemVersion))"
    
    private var concreteBle: ConcreteBLESensor?;

    public init(_ payloadDataSupplier: PayloadDataSupplier) {
        logger.debug("init")
        // Location sensor is necessary for enabling background BLE advert detection
        // NOT REQUIRED: sensorArray.append(ConcreteGPSSensor(rangeForBeacon: UUID(uuidString:  BLESensorConfiguration.serviceUUID.uuidString)))
        // BLE sensor for detecting and tracking proximity
        concreteBle = ConcreteBLESensor(payloadDataSupplier)
        sensorArray.append(concreteBle!)
        // Payload data at initiation time for identifying this device in the logs
        payloadData = payloadDataSupplier.payload(PayloadTimestamp())
        super.init()
        
        // Loggers
        add(delegate: ContactLog(filename: "contacts.csv"))
        add(delegate: StatisticsLog(filename: "statistics.csv", payloadData: payloadData))
        add(delegate: DetectionLog(filename: "detection.csv", payloadData: payloadData))
        _ = BatteryLog(filename: "battery.csv")
        logger.info("DEVICE (payloadPrefix=\(payloadData.shortName),description=\(SensorArray.deviceDescription))")
    }
    
    public func immediateSend(data: Data, _ targetIdentifier: TargetIdentifier) -> Bool {
        return concreteBle!.immediateSend(data: data,targetIdentifier);
    }
    
    public func add(delegate: SensorDelegate) {
        sensorArray.forEach { $0.add(delegate: delegate) }
    }
    
    public func start() {
        logger.debug("start")
        sensorArray.forEach { $0.start() }
    }
    
    public func stop() {
        logger.debug("stop")
        sensorArray.forEach { $0.stop() }
    }
}

