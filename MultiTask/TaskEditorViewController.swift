//
//  EditTaskViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/4/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

protocol TaskEditorViewControllerDelegate: NSObjectProtocol {
    func taskEditorViewController(_ viewController: TaskEditorViewController, didTapSave button: UIButton, toSave task: Task)
    func taskEditorViewController(_ viewController: TaskEditorViewController, didTapCancel button: UIButton)
}

class TaskEditorViewController: BaseViewController, UITextViewDelegate {

    // MARK: - API

    var task: Task?
    var delegate: TaskEditorViewControllerDelegate?
    static let storyboard_id = String(describing: TaskEditorViewController.self)

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    @IBAction func handleCancel(_ sender: UIButton) {
        self.textViewDidEndEditing(titleTextView)
        self.delegate?.taskEditorViewController(self, didTapCancel: sender)
    }

    @IBAction func handleSave(_ sender: UIButton) {
        self.textViewDidEndEditing(titleTextView)
        if !titleTextView.text.isEmpty {
            let newTask = self.createNewTask(taskTitle: titleTextView.text)
            self.delegate?.taskEditorViewController(self, didTapSave: sender, toSave: newTask)
        }
    }

    func createNewTask(taskTitle: String) -> Task {
        let task = Task(title: taskTitle, items: List<Item>(), is_completed: false)
        return task
    }

    private func setupView() {
        if self.task == nil {
            self.titleLabel.text = "Add a new task"
            self.titleTextView.text?.removeAll()
        } else {
            self.titleLabel.text = "Edit a task"
            self.titleTextView.text = task?.title
        }
        self.containerView.backgroundColor = Color.clear
        self.containerView.clipsToBounds = true
        self.contentContainerView.backgroundColor = Color.inkBlack
        self.contentContainerView.layer.borderColor = Color.midNightBlack.cgColor
        self.contentContainerView.layer.borderWidth = 3
        self.contentContainerView.layer.cornerRadius = 8
        self.contentContainerView.clipsToBounds = true
        self.titleLabel.textColor = Color.lightGray
        self.titleLabel.backgroundColor = Color.clear
        self.titleTextView.tintColor = Color.mandarinOrange
        self.titleTextView.backgroundColor = Color.midNightBlack
        self.titleTextView.layer.cornerRadius = 8
        self.titleTextView.clipsToBounds = true
        self.cancelButton.backgroundColor = Color.midNightBlack
        self.cancelButton.layer.cornerRadius = 8
        self.cancelButton.clipsToBounds = true
        self.cancelButton.setTitleColor(Color.white, for: UIControlState.normal)
        self.cancelButton.setTitle("Cancel", for: UIControlState.normal)
        self.saveButton.backgroundColor = Color.seaweedGreen
        self.saveButton.layer.cornerRadius = 8
        self.saveButton.clipsToBounds = true
        self.saveButton.setTitleColor(Color.white, for: UIControlState.normal)
        self.saveButton.setTitle("Save", for: UIControlState.normal)
    }

    // MARK: - UITextViewDelegate

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.titleTextView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.titleTextView.resignFirstResponder()
    }

}