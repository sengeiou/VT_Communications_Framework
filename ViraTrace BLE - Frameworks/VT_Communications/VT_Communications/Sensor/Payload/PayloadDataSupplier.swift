///**
/**



Created by: Wayne Thornton on 11/10/20
Portions Copyright © 2020 to Present ViraTrace LLC. All Rights Reserved.

This file contains Original Code and/or Modifications of Original code as defined in and that are subject to the ViraTrace Public Source License Version 1.0 (the ‘License’). You may not use this file except in compliance with the License. Please obtain of copy of the Licenses at https://github.com/ViraTrace/License and read it before using this file.

The Original Code and all software distributed under the License are distributed on an ‘AS IS’ basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND VIRATRACE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.

*/

import Foundation

/// Payload data supplier for generating payload data that is shared with other devices to provide device identity information while maintaining privacy and security.
/// Implement this to integration your solution with this transport.
public protocol PayloadDataSupplier {
    /// Get payload for given timestamp. Use this for integration with any payload generator.
    func payload(_ timestamp: PayloadTimestamp) -> PayloadData
    
    /// Parse raw data into payloads. This is used to split concatenated payloads that are transmitted via share payload. The default implementation assumes payload data is fixed length.
    func payload(_ data: Data) -> [PayloadData]
}

/// Implements payload splitting function, assuming fixed length payloads.
public extension PayloadDataSupplier {
    /// Default implementation assumes fixed length payload data.
    func payload(_ data: Data) -> [PayloadData] {
        // Get example payload to determine length
        let fixedLengthPayload = payload(PayloadTimestamp())
        let payloadLength = fixedLengthPayload.count
        // Split data into payloads based on fixed length
        var payloads: [PayloadData] = []
        var indexStart = 0, indexEnd = payloadLength
        while indexEnd <= data.count {
            let payload = PayloadData(data.subdata(in: indexStart..<indexEnd))
            payloads.append(payload)
            indexStart += payloadLength
            indexEnd += payloadLength
        }
        return payloads
    }
}

/// Payload timestamp, should normally be Date, but it may change to UInt64 in the future to use server synchronised relative timestamp.
public typealias PayloadTimestamp = Date

/// Encrypted payload data received from target. This is likely to be an encrypted datagram of the target's actual permanent identifier.
public typealias PayloadData = Data

public extension PayloadData {
    var shortName: String {
        return String(subdata(in: 3..<count-3).base64EncodedString().prefix(6))
    }
}


