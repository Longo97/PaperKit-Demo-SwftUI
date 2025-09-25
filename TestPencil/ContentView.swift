//
//  ContentView.swift
//  TestPencil
//
//  Created by Marco Longobardi on 17/09/25.
//

import SwiftUI
import UIKit
import PaperKit
import PencilKit

struct ContentView: View {
    
    var body: some View {
        NavigationStack {
            MarkupView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}

struct MarkupView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        var featureSet = FeatureSet.latest
        featureSet.colorMaximumLinearExposure = 4
        let markupModel = PaperMarkup(bounds: viewController.view.bounds)
        let paperVC = PaperMarkupViewController(markup: markupModel, supportedFeatureSet: featureSet)
        
        viewController.view.addSubview(paperVC.view)
        viewController.addChild(paperVC)
        paperVC.didMove(toParent: viewController)
        paperVC.view.backgroundColor = .systemBackground
        context.coordinator.paperVC = paperVC
        DispatchQueue.main.async {
            paperVC.becomeFirstResponder()
        }
        
        if context.coordinator.toolpicker == nil {
            let toolpicker = PKToolPicker()
            toolpicker.colorMaximumLinearExposure = 4
            context.coordinator.toolpicker = toolpicker
            toolpicker.setVisible(true, forFirstResponder: paperVC)
            toolpicker.addObserver(paperVC)
            paperVC.pencilKitResponderState.activeToolPicker = toolpicker
            paperVC.pencilKitResponderState.toolPickerVisibility = .visible

            // Accessory item with target-action routed to Coordinator
            let accessory = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: context.coordinator,
                action: #selector(Coordinator.plusButtonPressed(_:))
            )
            toolpicker.accessoryItem = accessory
        }
        return viewController
    }

    func updateUIViewController(_ paperVC: UIViewController, context: Context) {
        print("Do update")
    }

    class Coordinator: NSObject {
        weak var paperVC: PaperMarkupViewController?
        var toolpicker: PKToolPicker?

        @objc func plusButtonPressed(_ button: UIBarButtonItem) {
            guard let paperVC else { return }
            var featureSet = FeatureSet.latest
            featureSet.colorMaximumLinearExposure = 4
            let markupEditViewController = MarkupEditViewController(supportedFeatureSet: featureSet)
            markupEditViewController.delegate = paperVC as? any MarkupEditViewController.Delegate
            markupEditViewController.modalPresentationStyle = .popover
            markupEditViewController.popoverPresentationController?.barButtonItem = button
            paperVC.present(markupEditViewController, animated: true)
        }
    }
}
