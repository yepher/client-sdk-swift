//
//  File.swift
//  
//
//  Created by Russell D'Sa on 12/30/20.
//

import Foundation

public class RemoteDataTrackPublication: RemoteTrackPublication, DataTrackPublication {
    public var dataTrack: DataTrack? {
        get {
            return track as? DataTrack
        }
    }
}