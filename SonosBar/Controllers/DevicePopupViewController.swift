//
//  ViewController.swift
//  SonosController
//
//  Created by Nicolas Langley on 2/28/15.
//  Copyright (c) 2015 Nicolas Langley. All rights reserved.
//

import Cocoa
import AppKit

class DevicePopupViewController: NSViewController {
    
    // MARK: Global Variables
    // Global reference to view components
    var prevButton: NSButton!
    var nextButton: NSButton!
    var playbackButton: NSButton!
    var currentDeviceLabel: NSTextField!
    var trackInfoLabel: NSTextField!
    var volumeSlider: NSSlider!
    
    // Global AppDelegate reference
    var appDelegate: AppDelegate!
    
    // Global reference to current device
    var currentDevice: SonosController? = nil
    var sonosCoordinators: [SonosController]?

    // MARK: Interface Functions
    
    override func loadView() {
        // Create the view
        view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(
            item: view, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 280))
        view.addConstraint(NSLayoutConstraint(
            item: view, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 140))
        
        // Create the playback control buttons
        let playbackButton = NSButton()
        self.playbackButton = playbackButton
        playbackButton.title = "Play/Pause"
        playbackButton.target = self
        playbackButton.action = #selector(DevicePopupViewController.playbackTogglePressed(_:))
        playbackButton.image = NSImage(named: "play-button")
        playbackButton.imagePosition = NSCellImagePosition.imageOnly
        playbackButton.isBordered = false
        playbackButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playbackButton)
        
        let nextButton = NSButton()
        self.nextButton = nextButton
        nextButton.title = "Next"
        nextButton.target = self
        nextButton.action = #selector(DevicePopupViewController.nextPressed(_:))
        nextButton.image = NSImage(named: "next-button")
        nextButton.imagePosition = NSCellImagePosition.imageOnly
        nextButton.isBordered = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        
        let prevButton = NSButton()
        self.prevButton = prevButton
        prevButton.title = "Prev"
        prevButton.target = self
        prevButton.action = #selector(DevicePopupViewController.prevPressed(_:))
        prevButton.image = NSImage(named: "prev-button")
        prevButton.imagePosition = NSCellImagePosition.imageOnly
        prevButton.isBordered = false
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(prevButton)
        
        let quitButton = NSButton()
        quitButton.title = "Quit"
        quitButton.target = self
        quitButton.action = #selector(DevicePopupViewController.quitPressed(_:))
        quitButton.image = NSImage(named: "quit-button")
        quitButton.imagePosition = NSCellImagePosition.imageOnly
        quitButton.isBordered = false
        quitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quitButton)
        
        // Add button for opening Sonos Controller app
        let sonosAppButton = NSButton()
        sonosAppButton.title = "Sonos App"
        sonosAppButton.target = self
        sonosAppButton.action = #selector(DevicePopupViewController.sonosAppPressed(_:))
        sonosAppButton.image = NSImage(named: "sonos-app-button")
        sonosAppButton.imagePosition = NSCellImagePosition.imageOnly
        sonosAppButton.isBordered = false
        sonosAppButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sonosAppButton)
        
        // Create label for currently playing device
        let currentDeviceLabel = NSTextField()
        self.currentDeviceLabel = currentDeviceLabel
        currentDeviceLabel.stringValue = "Current Device"
        currentDeviceLabel.alignment = NSLeftTextAlignment
        currentDeviceLabel.isEditable = false
        currentDeviceLabel.isSelectable = false
        currentDeviceLabel.drawsBackground = false
        currentDeviceLabel.isBezeled = false
        currentDeviceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentDeviceLabel)
        
        // Create Label for track info
        let trackInfoLabel = NSTextField()
        self.trackInfoLabel = trackInfoLabel
        trackInfoLabel.stringValue = "Track Info"
        trackInfoLabel.alignment = NSCenterTextAlignment
        trackInfoLabel.isEditable = false
        trackInfoLabel.isSelectable = false
        trackInfoLabel.drawsBackground = false
        trackInfoLabel.isBezeled = false
        trackInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackInfoLabel)
        
        // Create volume slider control
        let volumeSlider = NSSlider()
        self.volumeSlider = volumeSlider
        volumeSlider.target = self
        volumeSlider.action = #selector(DevicePopupViewController.volumeChanged(_:))
        volumeSlider.maxValue = 100.0
        volumeSlider.minValue = 0.0
        volumeSlider.isContinuous = true
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(volumeSlider)
        
        
        // Add constraints to the view
        // Horizontal
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(30)-[prevButton(playbackButton)]-[playbackButton]-[nextButton(playbackButton)]-(30)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["playbackButton":playbackButton, "prevButton":prevButton, "nextButton":nextButton]))
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(20)-[trackInfoLabel]-(20)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["trackInfoLabel":trackInfoLabel]))
        
        //Vertical
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(15)-[trackInfoLabel(20)]-[playbackButton]-[volumeSlider(20)]-(25)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["playbackButton":playbackButton, "trackInfoLabel":trackInfoLabel, "volumeSlider":volumeSlider]))
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(15)-[trackInfoLabel(20)]-[prevButton]-[volumeSlider(20)]-(25)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["prevButton":prevButton, "trackInfoLabel":trackInfoLabel, "volumeSlider":volumeSlider]))
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(15)-[trackInfoLabel(20)]-[nextButton]-[volumeSlider(20)]-(25)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["nextButton":nextButton, "trackInfoLabel":trackInfoLabel, "volumeSlider":volumeSlider]))
        
        // Quit button constraints
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[quitButton(15.0)]-(5)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["quitButton":quitButton]))
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(5)-[quitButton(15.0)]",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["quitButton":quitButton]))
        
        // Sonos app button constraints
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(25)-[volumeSlider]-[sonosAppButton(20.0)]-(5)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["sonosAppButton":sonosAppButton, "volumeSlider":volumeSlider]))
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[sonosAppButton(20.0)]-(5)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["sonosAppButton":sonosAppButton]))
        
        // Current device label constraints
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(25)-[currentDeviceLabel]-[sonosAppButton(20.0)]-(5)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["currentDeviceLabel":currentDeviceLabel, "sonosAppButton":sonosAppButton]))
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[currentDeviceLabel(17.5)]-(5)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["currentDeviceLabel":currentDeviceLabel]))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get current device from appDelegate
        appDelegate = NSApplication.shared().delegate as! AppDelegate
        currentDevice = appDelegate.currentDevice
        sonosCoordinators = appDelegate.sonosCoordinators
    }
    
    override func viewWillAppear() {
        // View has been load into memory and is about to be added to view hierarchy
        // Update current device - gets whichever device is currently playing
        appDelegate.sonosManager?.refreshDevices()
        currentDevice = appDelegate.currentDevice
        self.currentDeviceLabel.stringValue = "Controlling: \(currentDevice!.name as String)"
        currentDevice!.playbackStatus({
            (playing, response, error)
            in
            if (error != nil) {
                print(error ?? "There was an error")
                // Check that device is still active
                self.appDelegate.sonosManager?.refreshDevices()
            } else {
                // Playback status was retrieved
                if (playing) {
                    // Set the correct title and icon
                    self.playbackButton.image = NSImage(named: "pause-button")
                    self.displayTrackInfo()
                } else {
                    // Set the correct title and icon
                    self.playbackButton.image = NSImage(named: "play-button")
                    self.trackInfoLabel.stringValue = "Nothing Playing"
                }
                // Sync volume slider
                self.setVolumeSlider()
            }
        })
    }
    
    // MARK: Display Functions
    
    /**
    Update display of current track info
    */
    func displayTrackInfo()
    {
        currentDevice!.trackInfo({
            (artist, title, album, albumArt, time, duration, queueIndex, trackURI, trackProtocol, error) -> Void
            in
            if (error != nil) {
                print(error ?? "There was an error")
            } else {
                let trackArtist = artist ?? "Unknown Artist"
                let trackTitle = title ?? "Unknown Track"
                
                self.trackInfoLabel.stringValue = "\(trackArtist) - \(trackTitle)"
            }
        })
    }
    
    // MARK: Volume Functions

    /**
    Set volume slider position to sync with Sonos volume
    */
    func setVolumeSlider()
    {
        currentDevice!.getVolume({
            (volume, response, error) -> Void
            in
            if (error != nil) {
                print(error ?? "There was an error")
            } else {
                self.volumeSlider.integerValue = volume as Int
            }
        })
    }
    
    /**
    Update Sonos volume according to volume slider
    */
    func volumeChanged(_ sender: AnyObject)
    {
        let sliderVolumeValue = self.volumeSlider.integerValue
        currentDevice!.setVolume(sliderVolumeValue, completion: {
            (response, error)
            in
            if (error != nil) {
                print(error ?? "There was an error")
            } else {
                print(response ?? "Response received")
            }
        })
        
    }
    
    // MARK: View Button Handlers
    
    /**
    Handle pressing of toggle playback in status bar menu
    */
    func playbackTogglePressed(_ sender: AnyObject)
    {
        currentDevice!.playbackStatus({
            (playing, response, error)
            in
            if (error != nil) {
                print(error ?? "There was an error")
            } else {
                // Playback status was retrieved
                if (playing) {
                    self.currentDevice!.pause({
                        (response, error) -> Void
                        in
                        if (error != nil) {
                            print(error ?? "There was an error")
                        } else {
                            print(response ?? "Response received")
                            // Set the correct title and icon
                            self.playbackButton.image = NSImage(named: "play-button")
                            self.displayTrackInfo()
                        }
                    })
                } else {
                    self.currentDevice!.play(nil, completion: {
                        (response, error) -> Void
                        in
                        if (error != nil) {
                            print(error ?? "There was an error")
                        } else {
                            print(response ?? "Response received")
                            // Set the correct title and icon
                            self.playbackButton.image = NSImage(named: "pause-button")
                            self.displayTrackInfo()
                        }
                    })
                }
            }
        })
    }
    
    /**
    Handle pressing of next option in status bar menu
    */
    func nextPressed(_ sender: AnyObject)
    {
        currentDevice!.next({
            (response, error) -> Void
            in
            if (error != nil) {
                print(error ?? "There was an error")
            } else {
                self.displayTrackInfo()
                print(response ?? "Response received")
            }
        })
    }
    
    /**
    Handle pressing of previous option in status bar menu
    */
    func prevPressed(_ sender: AnyObject)
    {
        currentDevice!.previous({
            (response, error) -> Void
            in
            if (error != nil) {
                print(error ?? "There was an error")
            } else {
                self.displayTrackInfo()
            }
            print(response ?? "Response received")
        })
    }
    
    /**
    Handle pressing of sonos app button
    */
    func sonosAppPressed(_ sender: AnyObject)
    {
        // Launch Sonos Controller app
        NSWorkspace.shared().launchApplication(withBundleIdentifier: "com.sonos.macController",
            options: NSWorkspaceLaunchOptions.default, additionalEventParamDescriptor: nil, launchIdentifier: nil)
    }
    
    /**
    Handle pressing of quit option in status bar menu
    */
    func quitPressed(_ sender: AnyObject)
    {
        print("Application Shutting Down...")
        NSApplication.shared().terminate(self)
    }

    

}

