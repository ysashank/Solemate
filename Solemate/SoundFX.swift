//
//  SoundFX.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 31.08.25.
//

import AudioToolbox

final class SoundFX {
    static let shared = SoundFX()

    private var startID: SystemSoundID = 0
    private var endID:   SystemSoundID = 0
    private var warnID:  SystemSoundID = 0

    private init() {
        startID = Self.load("start")
        endID   = Self.load("end")
        warnID  = Self.load("warn")
    }

    deinit {
        AudioServicesDisposeSystemSoundID(startID)
        AudioServicesDisposeSystemSoundID(endID)
        AudioServicesDisposeSystemSoundID(warnID)
    }

    func playStart() { if startID != 0 { AudioServicesPlaySystemSound(startID) } }
    func playEnd()   { if endID   != 0 { AudioServicesPlaySystemSound(endID) } }
    func playWarn()  { if warnID  != 0 { AudioServicesPlaySystemSound(warnID) } }

    private static func load(_ name: String) -> SystemSoundID {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return 0 }
        var id: SystemSoundID = 0
        let status = AudioServicesCreateSystemSoundID(url as CFURL, &id)
        return (status == kAudioServicesNoError) ? id : 0
    }
}
