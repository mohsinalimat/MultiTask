//
//  MainTasksPageViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/11/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class TasksPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIScrollViewDelegate, UIPageViewControllerDelegate {

    var pendingTasksViewController: PendingTasksViewController?
    var completedTasksViewController: CompletedTasksViewController?
    var mainTasksViewController: MainTasksViewController?
    var pages: [BaseViewController]!

    static let storyboard_id = String(describing: TasksPageViewController.self)

    private func getViewController(withIdentifier identifier: String, in storyboard: String) -> BaseViewController {
        return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: identifier) as! BaseViewController
    }

    private func setupPageViewController() {
        let storyboard = UIStoryboard(name: "TasksTab", bundle: nil)
        pendingTasksViewController = storyboard.instantiateViewController(withIdentifier: PendingTasksViewController.storyboard_id) as? PendingTasksViewController
        completedTasksViewController = storyboard.instantiateViewController(withIdentifier: CompletedTasksViewController.storyboard_id) as? CompletedTasksViewController
        pages = [pendingTasksViewController!, completedTasksViewController!]
        self.dataSource = self
        self.delegate = self
        if let firstViewController = pages.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: false, completion: nil)
        }
    }

    func goToNextPage(animated: Bool = true) {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) else { return }
        setViewControllers([nextViewController], direction: .forward, animated: animated, completion: nil)
    }

    func goToPreviousPage(animated: Bool = true) {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController(self, viewControllerBefore: currentViewController) else { return }
        setViewControllers([previousViewController], direction: .reverse, animated: animated, completion: nil)
    }

    // MARK: - UIScrollViewDelegate

    private func setupScrollViewDelegate() {
        for view in self.view.subviews {
            if let view = view as? UIScrollView {
                view.delegate = self
                break
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.x)

    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.x)
//        let itemPosition = Int((scrollView.contentOffset.x / 2) / (self.view.frame.width))
//        let indexPath = IndexPath(item: itemPosition, section: 0)
//        self.mainTasksViewController?.menuBarViewController?.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
    }

    func scrollToPageIndex(pageIndex: Int) {
        // manually scroll pageView to the next or previous page by menuIndex
        // FIXME: breakable logic, not scalable to 3 indices
        if pageIndex == 1 {
            self.goToNextPage()
        } else if pageIndex == 0 {
            self.goToPreviousPage()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPageViewController()
        self.setupScrollViewDelegate()
    }

    // MARK: - UIPageViewControllerDelegate

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            // FIXME: extremely hacky
            if let previousViewController = previousViewControllers.first as? PendingTasksViewController {
                print(previousViewController.PAGE_INDEX, #file, #line)
                let currentPageIndexPathAgainstMenuBar = IndexPath(item: 1, section: 0)
                self.mainTasksViewController?.menuBarViewController?.collectionView.selectItem(at: currentPageIndexPathAgainstMenuBar, animated: true, scrollPosition: [])
                self.mainTasksViewController?.menuBarViewController?.indicatorBar(scrollTo: self.view.frame.width / 2)
            } else if let previousViewController = previousViewControllers.first as? CompletedTasksViewController {
                print(previousViewController.PAGE_INDEX, #file, #line)
                let currentPageIndexPathAgainstMenuBar = IndexPath(item: 0, section: 0)
                self.mainTasksViewController?.menuBarViewController?.collectionView.selectItem(at: currentPageIndexPathAgainstMenuBar, animated: true, scrollPosition: [])
                self.mainTasksViewController?.menuBarViewController?.indicatorBar(scrollTo: 0)
            }
        }
    }

    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: CompletedTasksViewController.self) {
            return getViewController(withIdentifier: PendingTasksViewController.storyboard_id, in: "TasksTab")
        } else if viewController.isKind(of: PendingTasksViewController.self) {
            return nil
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: PendingTasksViewController.self) {
            return getViewController(withIdentifier: CompletedTasksViewController.storyboard_id, in: "TasksTab")
        } else if viewController.isKind(of: CompletedTasksViewController.self) {
            return nil
        }
        return nil
    }

}











