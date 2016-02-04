import UIKit
import WordPressShared

struct PlanListRow: ImmuTableRow {
    static let cell = ImmuTableCell.Class(WPTableViewCellSubtitle)
    static let customHeight: Float? = 92

    let title: String
    let active: Bool
    let price: String
    let description: String
    let icon: UIImage

    let action: ImmuTableAction? = nil
    
    let titleAttributes = [
        NSFontAttributeName: WPStyleGuide.tableviewTextFont(),
        NSForegroundColorAttributeName: WPStyleGuide.tableViewActionColor()
    ]
    let priceAttributes = [
        NSFontAttributeName: WPFontManager.openSansRegularFontOfSize(14.0),
        NSForegroundColorAttributeName: WPStyleGuide.darkGrey()
    ]
    let pricePeriodAttributes = [
        NSFontAttributeName: WPFontManager.openSansItalicFontOfSize(13.0),
        NSForegroundColorAttributeName: WPStyleGuide.greyLighten20()
    ]
    
    func configureCell(cell: UITableViewCell) {
        WPStyleGuide.configureTableViewSmallSubtitleCell(cell)
        cell.imageView?.image = icon
        cell.textLabel?.attributedText = attributedTitle
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.text = description
        cell.detailTextLabel?.textColor = WPStyleGuide.grey()
        cell.selectionStyle = .None
    }

    var attributedTitle: NSAttributedString {
        let planTitle = NSAttributedString(string: title, attributes: titleAttributes)

        let attributedTitle = NSMutableAttributedString(attributedString: planTitle)

        if active {
            let currentPlanAttributes = [
                NSFontAttributeName: WPFontManager.openSansSemiBoldFontOfSize(11.0),
                NSForegroundColorAttributeName: WPStyleGuide.validGreen()
            ]
            let currentPlan = NSLocalizedString("Current Plan", comment: "").uppercaseStringWithLocale(NSLocale.currentLocale())
            let attributedCurrentPlan = NSAttributedString(string: currentPlan, attributes: currentPlanAttributes)
            attributedTitle.appendString(" ")
            attributedTitle.appendAttributedString(attributedCurrentPlan)
        } else if !price.isEmpty {
            attributedTitle.appendString(" ")
            let attributedPrice = NSAttributedString(string: price, attributes: priceAttributes)
            attributedTitle.appendAttributedString(attributedPrice)

            attributedTitle.appendString(" ")
            let pricePeriod = NSAttributedString(string: NSLocalizedString("per year", comment: ""), attributes: pricePeriodAttributes)
            attributedTitle.appendAttributedString(pricePeriod)
        }
        return attributedTitle
    }
}

final class PlanListViewController: UITableViewController {
    private lazy var handler: ImmuTableViewHandler = {
        return ImmuTableViewHandler(takeOver: self)
    }()

    let activePlan: Plan?

    convenience init(blog: Blog) {
        self.init(activePlan: blog.plan)
    }

    init(activePlan: Plan?) {
        self.activePlan = activePlan
        super.init(style: .Grouped)
        title = NSLocalizedString("Plans", comment: "Title for the plan selector")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        WPStyleGuide.resetReadableMarginsForTableView(tableView)
        WPStyleGuide.configureColorsForView(view, andTableView: tableView)
        ImmuTable.registerRows([PlanListRow.self], tableView: tableView)
        bindViewModel()
    }

    func bindViewModel() {
        handler.viewModel = ImmuTable(sections: [
            ImmuTableSection(
                headerText: NSLocalizedString("WordPress.com Plans", comment: "Title for the Plans list header"),
                rows: [
                    rowForPlan(.Free),
                    rowForPlan(.Premium),
                    rowForPlan(.Business)
                ])
            ])
    }

    func rowForPlan(plan: Plan) -> PlanListRow {
        let active = (activePlan == plan)
        let icon = active ? plan.activeImage : plan.image

        return PlanListRow(
            title: plan.title,
            active: active,
            price: priceForPlan(plan),
            description: plan.description,
            icon: icon
        )
    }

    // TODO: Prices should always come from StoreKit
    // @koke 2016-02-02
    private func priceForPlan(plan: Plan) -> String {
        switch plan {
        case .Free:
            return ""
        case .Premium:
            return "$99.99"
        case .Business:
            return "$299.99"
        }
    }
}
