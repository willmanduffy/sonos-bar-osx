//
//  AppDelegate.swift
//  SonosController
//
//  Created by Nicolas Langley on 2/28/15.
//  Copyright (c) 2015 Nicolas Langley. All rights reserved.
//

import Cocoa

@NSApplicationMain
open class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: Global Variables
    
    var statusBar = NSStatusBar.system()
    var statusBarItem: NSStatusItem? = nil
    var popover: NSPopover = NSPopover()
    var popoverTransiencyMonitor: AnyObject? = nil
    // Context for Key-Value Observer
    fileprivate var allDevicesContext: UInt8 = 1
    fileprivate var currentDeviceContext: UInt8 = 2
    
    var sonosManager: SonosManager? = nil
    var sonosDevices: [SonosController] = []
    var currentDevice: SonosController? = nil
    var sonosCoordinators: [SonosController] = []
    
    // MARK: Interface Functions
    
    open func applicationWillFinishLaunching(_ aNotification: Notification)
    {
        // Find the available Sonos devices
        sonosManager = SonosManager.sharedInstance() as? SonosManager
        sonosManager!.addObserver(self, forKeyPath: "allDevices", options: NSKeyValueObservingOptions.new, context: &allDevicesContext)
        sonosManager!.addObserver(self, forKeyPath: "currentDevice", options: NSKeyValueObservingOptions.new, context: &currentDeviceContext)
    }

    // MARK: Setup Functions
    
    /**
    Key-Value Observer for allDevices key
    */
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if (context == &allDevicesContext)
        {
            sonosCoordinators.removeAll(keepingCapacity: false)
            sonosCoordinators = sonosManager?.coordinators as! [SonosController]
            if (sonosCoordinators.isEmpty)
            {
                print("No devices found")
                // Set up the menubar
                self.currentDevice = nil
                self.menuBarSetup()
            }
            else
            {
                for coordinator in sonosCoordinators
                {
                    if (coordinator.name != "BRIDGE")
                    {
                        self.currentDevice = coordinator
                        print("Setting default device: \(currentDevice!.name)")
                        break
                    }
                }
            }
            
        }
        else if (context == &currentDeviceContext)
        {
            if (!(sonosManager?.currentDevice!.name == "BRIDGE"))
            {
                self.currentDevice = sonosManager?.currentDevice
                print("Setting current device: \(self.currentDevice!.name)")
                self.menuBarSetup()
            }
        }
    }
    
    /**
    Setup menubar status item
    */
    open func menuBarSetup()
    {
        // Add statusBarItem to status bar
        if (statusBarItem == nil) {
            statusBarItem = statusBar.statusItem(withLength: -1)
            statusBarItem!.image = NSImage(named: "sonos-icon-round")
            if let statusButton = statusBarItem!.button {
                statusButton.action = #selector(AppDelegate.handlePopover(_:))
            }
            // Create popup for info and controls
            popover = NSPopover()
            popover.behavior = NSPopoverBehavior.transient
        }
        // Set view controller depending on if a device is found
        if (self.currentDevice == nil) {
            popover.contentViewController = NoDevicePopupViewController()
        } else if let _ = popover.contentViewController as? NoDevicePopupViewController {
            popover.contentViewController = DevicePopupViewController()
        } else if (popover.contentViewController == nil) {
            popover.contentViewController = DevicePopupViewController()
        }
    }
    
    // MARK: Popover Functions
    
    /**
    Handle opening/closing of popover on button press
    */
    func handlePopover(_ sender: AnyObject)
    {
        if let _ = statusBarItem!.button {
            if popover.isShown {
                popover.close()
            } else {
                self.openPopover(sender)
            }
        }
    }
    
    /**
    Open popover and add transiency monitor
    */
    func openPopover(_ sender: AnyObject)
    {
        if let statusButton = statusBarItem!.button {
            popoverTransiencyMonitor = NSEvent.addGlobalMonitorForEvents(matching: [NSEventMask.leftMouseDown, NSEventMask.rightMouseDown],
                handler: {(event) -> Void
                    in
                    self.closePopover(sender)
            }) as AnyObject?
            popover.show(relativeTo: NSZeroRect, of: statusButton, preferredEdge: NSRectEdge.minY)
        }
    }
    
    /**
    Closing of popover and remove transiency monitor
    */
    func closePopover(_ sender: AnyObject)
    {
        if (popoverTransiencyMonitor != nil) {
            NSEvent.removeMonitor(popoverTransiencyMonitor!)
            popoverTransiencyMonitor = nil
        }
        self.popover.close()
    }
}

