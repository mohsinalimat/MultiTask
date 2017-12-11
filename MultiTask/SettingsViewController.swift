//
//  SettingsViewController.swift
//  MultiTask
//
//  Created by rightmeow on 12/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class SettingsViewController: UITableViewController, PersistentContainerDelegate {

    // MARK: - API

    var realmManager: RealmManager?

    static let storyboard_id = String(describing: SettingsViewController.self)

    @IBOutlet weak var profileCell: UITableViewCell!
    @IBOutlet weak var avatarFrameView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarFrameViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userStatusLabel: UILabel!

    @IBOutlet weak var settingsCell: UITableViewCell!
    @IBOutlet weak var themeImageView: UIImageView!
    @IBOutlet weak var themeTitleLabel: UILabel!
    @IBOutlet weak var themeSwitch: UISwitch!

    @IBOutlet weak var agreementCell: UITableViewCell!
    @IBOutlet weak var agreementImageView: UIImageView!
    @IBOutlet weak var agreementLabel: UILabel!

    @IBOutlet weak var supportCell: UITableViewCell!
    @IBOutlet weak var supportImageView: UIImageView!
    @IBOutlet weak var supportLabel: UILabel!

    @IBOutlet weak var bugCell: UITableViewCell!
    @IBOutlet weak var bugImageView: UIImageView!
    @IBOutlet weak var bugLabel: UILabel!

    @IBAction func handleThemeSwitch(_ sender: UISwitch) {
        print(123)
    }

    // MARK: - PersistentContainerDelegate

    private func setupPersistentContainerDelegate() {
        self.realmManager = RealmManager()
        self.realmManager!.delegate = self
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }

    func persistentContainer(_ manager: RealmManager, didFetchUsers users: Results<User>?) {
        if let existingUser = users?.first {
            self.avatarImageView.image = #imageLiteral(resourceName: "RubberDuck") // <<-- image literal
            self.userIdLabel.text = "ID. " + existingUser.id
            self.userStatusLabel.text = "Local User"
        } else {
            self.avatarImageView.image = #imageLiteral(resourceName: "DeadEmoji")
            self.userIdLabel.text = "ID Not Found"
            self.userStatusLabel.text = "User Not Found"
            print(trace(file: #file, function: #function, line: #line))
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupCells()
        self.setupPersistentContainerDelegate()
        // perform fetch
        realmManager!.fetchExistingUsers()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == Segue.AgreementCellToWebsViewController {
            if let websViewController = segue.destination as? WebsViewController {
                websViewController.url = ExternalWebServiceUrlString.Terms
            }
        } else if segue.identifier == Segue.BugCellToWebsViewController {
            if let websViewController = segue.destination as? WebsViewController {
                websViewController.url = ExternalWebServiceUrlString.Trello
            }
        } else if segue.identifier == Segue.SupportCellToWebsViewController {
            if let websViewController = segue.destination as? WebsViewController {
                websViewController.url = ExternalWebServiceUrlString.FAQ
            }
        } else if segue.identifier == Segue.ProfileCellToWebsViewController {
            // TODO: implement this
        }
    }

    // MARK: - UITableView

    private func setupTableView() {
        self.tableView.backgroundColor = Color.inkBlack
        self.tableView.separatorStyle = .none
    }

    // MARK: - Static Cells

    private func setupCells() {
        // user section
        self.profileCell.backgroundColor = Color.midNightBlack
        self.avatarFrameView.backgroundColor = Color.inkBlack
        self.avatarFrameView.clipsToBounds = true
        self.avatarFrameView.layer.cornerRadius = self.avatarFrameViewHeightLayoutConstraint.constant / 2
        self.avatarFrameView.layer.borderWidth = 1
        self.avatarFrameView.layer.borderColor = Color.lightGray.cgColor
        self.avatarImageView.image = #imageLiteral(resourceName: "DeadEmoji") // <<-- image literal
        self.avatarImageView.backgroundColor = Color.clear
        self.avatarImageView.contentMode = .scaleAspectFill
        self.avatarImageView.enableParallaxMotion(magnitude: 14)
        self.userIdLabel.backgroundColor = Color.clear
        self.userIdLabel.textColor = Color.white
        self.userStatusLabel.backgroundColor = Color.clear
        self.userStatusLabel.textColor = Color.lightGray
        // settings section
        self.settingsCell.backgroundColor = Color.midNightBlack
        self.themeImageView.backgroundColor = Color.clear
        self.themeImageView.tintColor = Color.lightGray
        self.themeTitleLabel.backgroundColor = Color.clear
        self.themeTitleLabel.textColor = Color.white
        self.themeSwitch.backgroundColor = Color.clear
        self.themeSwitch.onTintColor = Color.seaweedGreen
        // about section
        self.agreementCell.backgroundColor = Color.midNightBlack
        self.agreementImageView.backgroundColor = Color.clear
        self.agreementImageView.tintColor = Color.lightGray
        self.agreementLabel.backgroundColor = Color.clear
        self.agreementLabel.textColor = Color.white
        // support section
        self.supportCell.backgroundColor = Color.midNightBlack
        self.supportImageView.backgroundColor = Color.clear
        self.supportImageView.tintColor = Color.lightGray
        self.supportLabel.backgroundColor = Color.clear
        self.supportLabel.textColor = Color.white
        self.bugCell.backgroundColor = Color.midNightBlack
        self.bugLabel.backgroundColor = Color.clear
        self.bugLabel.textColor = Color.white
        self.bugImageView.backgroundColor = Color.clear
        self.bugImageView.tintColor = Color.lightGray
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 92
        } else {
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 3 ? 60 : 0
    }

    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) {
            cell.backgroundColor = Color.mediumBlueGray
        }
    }

    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) {
            cell.backgroundColor = Color.midNightBlack
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                // profileCell
                // TODO: implement segue
//                self.performSegue(withIdentifier: Segue.ProfileCellToWebsViewController, sender: self)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                // this is the themeCell, no need for dependency injection
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                // agreementCell
                self.performSegue(withIdentifier: Segue.AgreementCellToWebsViewController, sender: self)
            }
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                // supportCell
                self.performSegue(withIdentifier: Segue.SupportCellToWebsViewController, sender: self)
            } else if indexPath.row == 1 {
                // bugCell
                self.performSegue(withIdentifier: Segue.BugCellToWebsViewController, sender: self)
            }
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "User"
        } else if section == 1 {
            return "Settings"
        } else if section == 2 {
            return "About"
        } else if section == 3 {
            return "Support"
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 3 {
            guard let appVersion = Bundle.main.releaseVersionNumber else { return nil }
            guard let buildVersion = Bundle.main.buildVersionNumber else { return nil }
            return "You are using MultiTask \(appVersion).\(buildVersion)"
        } else {
            return nil
        }
    }

}
