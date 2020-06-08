//
//  AboutVC.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/20.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit
import SafariServices

class AboutVC: BaseViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About ItemFinder"
        versionLabel.text = "Version：" + UIApplication.shared.appVersion!
    }

    @IBAction func onBtnClick(_ sender: UIButton) {
        let sf = SFSafariViewController(url: URL(string: "https://blog.csdn.net/huxinguang_ios")!)
        sf.preferredBarTintColor = UIColor.white
        sf.preferredControlTintColor = kAppThemeColor
        if #available(iOS 11.0, *){
            sf.dismissButtonStyle = .close
        }
        sf.modalPresentationStyle = .fullScreen
        present(sf, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
