//
//  DateTimePickerVC.swift
//  pos
//
//  Created by Ahmed Mahrous on 18/05/2025.
//  Copyright © 2025 khaled. All rights reserved.
//


import UIKit

// MARK: - Date helpers
private let gregorianUTC: Calendar = {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(secondsFromGMT: 0)!
    return cal
}()

// MARK: - Small day cell
private class DayCell: UICollectionViewCell {
    static let reuse = "DayCell"

    private let label = UILabel()
    private let circle = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        circle.backgroundColor = UIColor(red: 0.25, green: 0.49, blue: 0.96, alpha: 0.25)
        circle.layer.cornerRadius = 18
        circle.isHidden = true
        circle.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(circle)
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            circle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circle.widthAnchor.constraint(equalToConstant: 36),
            circle.heightAnchor.constraint(equalToConstant: 36),

            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(day: Int?, isSelected: Bool) {
        if let day = day {
            label.text = String(day)
            label.textColor = .black
        } else {
            label.text = nil
        }
        circle.isHidden = !isSelected
        label.textColor = isSelected ? .white : .black
    }
}

// MARK: - Calendar grid wrapper
private class CalendarGrid: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    var onDaySelected: ((Date) -> Void)?
    var currentMonth = gregorianUTC.date(from: gregorianUTC.dateComponents([.year, .month], from: Date()))! {
        didSet {
            reloadData()
        }
    }
    var selectedDate: Date? {
        didSet { reloadData() }
    }

   
    private let headerLabel = UILabel()
    private let collection: UICollectionView
    private let leftBtn = UIButton(type: .system)
    private let rightBtn = UIButton(type: .system)
    private let weekdayRow = UIStackView()

   
    private var days: [Int?] = []

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        build()
        reloadData()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func build() {
        // Header
        headerLabel.font = UIFont.boldSystemFont(ofSize: 17)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13.0, *) {
            leftBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        } else {
            leftBtn.setTitle("‹", for: .normal)
        }
        if #available(iOS 13.0, *) {
            rightBtn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        } else {
            rightBtn.setTitle("›", for: .normal)
        }
        
        [leftBtn, rightBtn].forEach { btn in
            btn.tintColor = .systemBlue
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.widthAnchor.constraint(equalToConstant: 44).isActive = true
        }
        leftBtn.addTarget(self, action: #selector(prevMonth), for: .touchUpInside)
        rightBtn.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        
        // Weekday row
        weekdayRow.axis = .horizontal
        weekdayRow.distribution = .fillEqually
        weekdayRow.translatesAutoresizingMaskIntoConstraints = false
        let symbols = gregorianUTC.shortStandaloneWeekdaySymbols // SUN … SAT
        for sym in symbols {
            let lab = UILabel()
            lab.text = sym.uppercased()
            lab.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            lab.textColor = .gray
            lab.textAlignment = .center
            weekdayRow.addArrangedSubview(lab)
        }
        
        // Collection view
        collection.dataSource = self
        collection.delegate = self
        collection.register(DayCell.self, forCellWithReuseIdentifier: DayCell.reuse)
        collection.backgroundColor = .clear
        collection.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout tree
        addSubview(headerLabel)
        addSubview(leftBtn)
        addSubview(rightBtn)
        addSubview(weekdayRow)
        addSubview(collection)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 24),
            
            leftBtn.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            leftBtn.leadingAnchor.constraint(equalTo: leadingAnchor),
            rightBtn.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            rightBtn.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            weekdayRow.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 4),
            weekdayRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            weekdayRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            weekdayRow.heightAnchor.constraint(equalToConstant: 18),
            
            collection.topAnchor.constraint(equalTo: weekdayRow.bottomAnchor, constant: 4),
            collection.leadingAnchor.constraint(equalTo: leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func reloadData() {
        // Build days array (6 rows × 7 cols = 42)
        days.removeAll()
        let range = gregorianUTC.range(of: .day, in: .month, for: currentMonth)!
        let totalDays = range.count
        let firstOfMonth = currentMonth
        let weekdayIndex = gregorianUTC.component(.weekday, from: firstOfMonth) // 1 … 7 (Sun =1)
        let leadingBlanks = weekdayIndex - 1
        days += Array(repeating: nil, count: leadingBlanks)
        days += (1...totalDays).map { Optional($0) }
        while days.count % 7 != 0 { days.append(nil) }
        // Ensure 6 rows
        while days.count < 42 { days.append(nil) }

        // Header text
        let fmt = DateFormatter()
        fmt.dateFormat = "LLLL yyyy"
        headerLabel.text = fmt.string(from: currentMonth)

        collection.reloadData()
    }

    // MARK: - Month nav
    @objc private func prevMonth() {
        if let newMonth = gregorianUTC.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    @objc private func nextMonth() {
        if let newMonth = gregorianUTC.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    // MARK: - UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 42 }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayCell.reuse, for: indexPath) as! DayCell
        let dayNumber = days[indexPath.item]
        var isSel = false
        if let dayNumber = dayNumber, let sel = selectedDate {
            let comps = gregorianUTC.dateComponents([.year, .month, .day], from: sel)
            let thisDate = dateFor(day: dayNumber)
            let tComps = gregorianUTC.dateComponents([.year, .month, .day], from: thisDate)
            isSel = comps == tComps
        }
        cell.configure(day: dayNumber, isSelected: isSel)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let day = days[indexPath.item] else { return }
        selectedDate = dateFor(day: day)
        onDaySelected?(selectedDate!)
    }

    private func dateFor(day: Int) -> Date {
        var comps = gregorianUTC.dateComponents([.year, .month], from: currentMonth)
        comps.day = day
        return gregorianUTC.date(from: comps)!
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7.0
        return CGSize(width: width, height: 40)
    }
}

// MARK: - Main picker VC
class DateTimePickerVC: UIViewController {

    var onPicked: ((_ date: String, _ time: String) -> Void)?

    var initialDate: Date = Date()

    private let calendarGrid = CalendarGrid()
    private let timeLabel = UILabel()
    private let timePicker = UIDatePicker()
    private let doneButton = UIButton(type: .system)
    private let card = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }

    private func buildUI() {
        selectedDay = initialDate
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)

        // Calendar
        calendarGrid.translatesAutoresizingMaskIntoConstraints = false
        calendarGrid.onDaySelected = { [weak self] date in
            self?.selectedDay = date
        }
        calendarGrid.selectedDate = initialDate
        calendarGrid.currentMonth = gregorianUTC.date(from: gregorianUTC.dateComponents([.year, .month], from: initialDate))!

        // Time label
        timeLabel.text = "Time"
        timeLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        // Time picker
        timePicker.datePickerMode = .time
        timePicker.timeZone = TimeZone(secondsFromGMT: 0)!
        timePicker.minuteInterval = 1
        timePicker.date = initialDate
        if #available(iOS 13.4, *) { timePicker.preferredDatePickerStyle = .automatic }
        timePicker.locale = Locale(identifier: "en_US_POSIX")
        timePicker.translatesAutoresizingMaskIntoConstraints = false

        // Done button
        doneButton.setTitle("Done".arabic("تم"), for: .normal)
        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        doneButton.setTitleColor(.systemBlue, for: .normal)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)

        // Add to card
        [calendarGrid, timeLabel, timePicker, doneButton].forEach { card.addSubview($0) }

        layout()
    }

    private func layout() {
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: view.topAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            calendarGrid.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            calendarGrid.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            calendarGrid.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            calendarGrid.heightAnchor.constraint(equalToConstant: 300)
        ])

        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: calendarGrid.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: calendarGrid.leadingAnchor)
        ])

        NSLayoutConstraint.activate([
            timePicker.topAnchor.constraint(equalTo: calendarGrid.bottomAnchor, constant: 8),
            timePicker.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: calendarGrid.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 16),
            doneButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Date merging
    private var selectedDay: Date?

    @objc private func confirm() {
        guard let day = selectedDay else { return }

        // Merge the picked day + time into a single UTC Date
        var comps       = Calendar.utc.dateComponents([.year, .month, .day], from: day)
        let timeComps   = Calendar.utc.dateComponents([.hour, .minute], from: timePicker.date)
        comps.hour      = timeComps.hour
        comps.minute    = timeComps.minute
        comps.second    = 0
        comps.timeZone  = TimeZone(secondsFromGMT: 0)

        guard let finalUTCDate = Calendar.utc.date(from: comps) else { return }

        // ----- formatters -----
        let dateFmt = DateFormatter()
        dateFmt.timeZone  = .utc
        dateFmt.dateFormat = "yyyy-MM-dd"      // or "yyyy-MM-dd hh:mm a"

        let timeFmt = DateFormatter()
        timeFmt.timeZone  = .utc
        timeFmt.dateFormat = "hh:mm a"           // or "HH:mm"

        let dateString = dateFmt.string(from: finalUTCDate)
        let timeString = timeFmt.string(from: finalUTCDate)

        onPicked?(dateString, timeString)

        dismiss(animated: true)
    }

}
