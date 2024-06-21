//
//  ToolTips.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 13.10.2023.
//

import Foundation
import SwiftUI
import TipKit

struct FileOptionsTip: Tip {
    var title: Text {
            Text("Show a list of options")
        }

    var message: Text? {
        Text("Tap the filename below, after you've uploaded a recording.")
    }

    var image: Image? {
        Image(systemName: "waveform")
    }
}

struct FileOptionsTipForIpad: Tip {
    var title: Text {
            Text("You can now")
        }

    var message: Text? {
        Text("Transcribe the voice to text or play the file.")
    }

    var image: Image? {
        Image(systemName: "waveform")
    }
}

struct TranscribedTextOptionsTip: Tip {
    var title: Text {
            Text("Copy to clipboard")
        }

    var message: Text? {
        Text("Tap the transcribed text to analyze it or copy it to the clipboard")
    }

    var image: Image? {
        Image(systemName: "arrow.right.doc.on.clipboard")
    }
}

struct TranscribedTextOptionsTipForIpad: Tip {
    var title: Text {
            Text("You can now")
        }

    var message: Text? {
        Text("Analyze the transcribed text or copy it to the clipboard")
    }

    var image: Image? {
        Image(systemName: "arrow.right.doc.on.clipboard")
    }
}

struct AnalyzedTextOptionsTip: Tip {
    var title: Text {
            Text("Copy to clipboard")
        }

    var message: Text? {
        Text("Tap the analyzed text to copy it to the clipboard")
    }

    var image: Image? {
        Image(systemName: "doc.text")
    }
}

struct AnalyzedTextOptionsTipForIpad: Tip {
    var title: Text {
            Text("Copy to clipboard")
        }

    var message: Text? {
        Text("Click on the text or use the button bellow to copy the analyzed text to the clipboard")
    }

    var image: Image? {
        Image(systemName: "doc.text")
    }
}
