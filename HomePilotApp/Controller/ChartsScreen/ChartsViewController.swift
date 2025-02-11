//
//  ChartsViewController.swift
//  HomePilotApp
//
//  Created by Helin Güler on 4.02.2025.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import Charts
import CoreData

class ChartsViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var chart1View: BarChartView!
    @IBOutlet weak var chart1SegmentedControl: UISegmentedControl!
        
    @IBOutlet weak var chart3View: LineChartView!
    @IBOutlet weak var chart3SegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var chart4View: HorizontalBarChartView!
    @IBOutlet weak var chart4SegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var chart5View: CombinedChartView!
    @IBOutlet weak var chart5SegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var chart2View: PieChartView!
    @IBOutlet weak var chart2SegmentedControl: UISegmentedControl!
    
    private var deviceUsages: [DeviceUsage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Her grafik için başlangıçta sadece bir kez veri çekiliyor.
        loadData(period: "weekly", chartIndex: 1)
        loadData(period: "weekly", chartIndex: 2)
        loadData(period: "weekly", chartIndex: 3)
        loadData(period: "weekly", chartIndex: 4)
        loadData(period: "weekly", chartIndex: 5)

        // Grafiklere interaktiflik eklemek için.
        chart1View.delegate = self
        chart2View.delegate = self
        chart3View.delegate = self
        chart4View.delegate = self
        chart5View.delegate = self
    }

    // SegmentedControl değiştirme
    @IBAction func periodChanged(_ sender: UISegmentedControl) {
        let selectedPeriod = sender.selectedSegmentIndex == 0 ? "weekly" : "monthly"

        if sender == chart1SegmentedControl {
            loadData(period: selectedPeriod, chartIndex: 1)
        } else if sender == chart2SegmentedControl {
            loadData(period: selectedPeriod, chartIndex: 2)
        } else if sender == chart3SegmentedControl {
            loadData(period: selectedPeriod, chartIndex: 3)
        } else if sender == chart4SegmentedControl {
            loadData(period: selectedPeriod, chartIndex: 4)
        }else if sender == chart5SegmentedControl {
            loadData(period: selectedPeriod, chartIndex: 5)
        }
    }

    // CoreData'dan veri çekme
    private func loadData(period: String, chartIndex: Int) {
        guard let currentUserUID = Auth.auth().currentUser?.uid,
        let currentUser = CoreDataManager.shared.fetchCurrentUser(uid: currentUserUID) else {
            print("No user logged in or user not found in Core Data.")
            return
        }

        let deviceUsages: [DeviceUsage]
        if period == "all" {
            // Tüm veriler için tarih filtresi yok
            deviceUsages = CoreDataManager.shared.fetchDeviceUsages(for: currentUser)
        } else {
            // Haftalık veya aylık veri çekmek için tarih aralığı belirleme
            let currentDate = Date()
            let startDate: Date = (period == "weekly") ?
            Calendar.current.date(byAdding: .day, value: -7, to: currentDate) ?? currentDate :
            Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
            deviceUsages = CoreDataManager.shared.fetchDeviceUsages(for: currentUser, from: startDate, to: currentDate)
        }

        // Sadece ilgili chart'ı güncellemek için
        switch chartIndex {
        case 1:
            update1Chart(period: period, deviceUsages: deviceUsages)
        case 2:
            update2Chart(period: period, deviceUsages: deviceUsages)
        case 3:
            update3Chart(period: period, deviceUsages: deviceUsages)
        case 4:
            update4Chart(period: period, deviceUsages: deviceUsages)
        case 5:
            update5Chart(period: period, deviceUsages: deviceUsages)
        default:
            break
        }
    }

    // 1. Grafik
    private func update1Chart(period: String, deviceUsages: [DeviceUsage]) {
        let deviceNames = ["AC", "Washer", "Combi", "AH", "Dishwasher", "Oven"]
        var deviceCostDictionary: [String: Double] = [:]
        
        for usage in deviceUsages {
            let normalizedDeviceName = normalizeDeviceName(usage.deviceName ?? "Unknown Device")
            deviceCostDictionary[normalizedDeviceName, default: 0.0] += usage.totalCost
        }

        let dataEntries: [BarChartDataEntry] = deviceNames.enumerated().map { (index, name) in
            return BarChartDataEntry(x: Double(index), y: deviceCostDictionary[name] ?? 0.0)
        }

        // DataSet oluşturma
        let dataSet = BarChartDataSet(entries: dataEntries, label: "Device Costs ($)")
        dataSet.colors = ChartColorTemplates.joyful()
        dataSet.valueTextColor = UIColor.black // Değerlerin yazı rengi
        dataSet.highlightEnabled = true // Vurgulama etkinleştirme
        dataSet.barShadowColor = UIColor.lightGray.withAlphaComponent(0.3) // Gölge rengi
        dataSet.drawValuesEnabled = false // Üzerinde sayı gösterme
    

        let data = BarChartData(dataSet: dataSet)
        chart1View.data = data
        /*
           chart1View.xAxis.valueFormatter = IndexAxisValueFormatter(values: deviceNames)
           chart1View.xAxis.labelPosition = .bottom // X ekseni etiketlerini altta göster
           //chart1View.xAxis.drawGridLinesEnabled = false // X ekseni ızgaralarını kapat
           //chart1View.leftAxis.drawGridLinesEnabled = false // Sol Y ekseni ızgaralarını kapat
           chart1View.rightAxis.enabled = false
           chart1View.xAxis.granularity = 1
           chart1View.animate(yAxisDuration: 1.0) // Animasyon ekleme
           chart1View.noDataText = "No data available"
         */
        let xAxis = chart1View.xAxis
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.valueFormatter = IndexAxisValueFormatter(values: deviceNames)
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 12, weight: .bold)

        let leftAxis = chart1View.leftAxis
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawLabelsEnabled = false

        let rightAxis = chart1View.rightAxis
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawLabelsEnabled = false

        chart1View.legend.enabled = false // Label'ı kaldır
        chart1View.animate(yAxisDuration: 1.0)

        // Gölgeli opacity
        chart1View.drawGridBackgroundEnabled = false
        chart1View.backgroundColor = .white
        chart1View.extraBottomOffset = 10
        
        // Custom marker
        let marker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: 60, height: 25))
        marker.chartView = chart1View
        chart1View.marker = marker
        
        chart1View.highlightPerDragEnabled = true // Parmağı kaydırarak bar seçme
        chart1View.highlightPerTapEnabled = true // Tıklayınca seçimi engelle
         
       }

       private func normalizeDeviceName(_ deviceName: String) -> String {
           switch deviceName.lowercased() {
           case "ac", "air conditioning":
               return "AC"
           case "washer", "washing machine":
               return "Washer"
           case "dishwasher":
               return "Dishwasher"
           case "combi", "Combi":
               return "Combi"
           case "humidifier", "air humidifier":
               return "AH"
           case "oven", "Oven":
               return "Oven"
           default:
               return "Unknown Device"
           }
       }
    
    
    // 2. Grafik
    private func update2Chart(period: String, deviceUsages: [DeviceUsage]) {
        var electricityCost = 0.0
        var waterCost = 0.0
        var gasCost = 0.0

        for usage in deviceUsages {
            electricityCost += usage.electricityCost
            waterCost += usage.waterCost
            gasCost += usage.gasCost
        }

        let totalCost = electricityCost + waterCost + gasCost
        if totalCost == 0 { return }

        let electricityPercentage = (electricityCost / totalCost) * 100
        let waterPercentage = (waterCost / totalCost) * 100
        let gasPercentage = (gasCost / totalCost) * 100
        
        let entries = [
            PieChartDataEntry(value: electricityPercentage, label: "Electricity ⚡", data: electricityCost),
            PieChartDataEntry(value: waterPercentage, label: "Water 💧", data: waterCost),
            PieChartDataEntry(value: gasPercentage, label: "Gas 🔥", data: gasCost)
        ]
        
        let dataSet = PieChartDataSet(entries: entries, label: "Cost")
        dataSet.colors = ChartColorTemplates.joyful()
        dataSet.valueTextColor = .black
        dataSet.valueFont = .systemFont(ofSize: 14, weight: .bold)
        
        // Etiketleri dışarı çekmek için leader lines (oklar)
        dataSet.yValuePosition = .outsideSlice  // Etiketleri dışarı alma
        dataSet.valueLinePart1OffsetPercentage = 0.8    // Ok uzunluğu
        dataSet.valueLinePart1Length = 0.4
        dataSet.valueLinePart2Length = 0.2
        dataSet.valueLineWidth = 1.2
        dataSet.valueLineColor = .darkGray
        dataSet.sliceSpace = 8.0    // Dilimler arasındaki boşluğu artırma
        //dataSet.selectionShift = 4.0  //Tıklayınca fazla büyümeyi engeller
        dataSet.xValuePosition = .outsideSlice   // Dilim isimlerini dışarı taşı
        
        // Yüzde olarak gösterme
        dataSet.valueFormatter = PercentFormatter()

        let data = PieChartData(dataSet: dataSet)
        chart2View.data = data
        chart2View.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutQuad)
        chart2View.legend.enabled = false // Legend kaldır (etiketler dışarıda!)
        chart2View.legend.yEntrySpace = 5
    }

    // Dilime tıklanınca cost değerini ortada gösterme
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let pieEntry = entry as? PieChartDataEntry, let costValue = pieEntry.data as? Double else { return }
        
        chart2View.centerText = "\(pieEntry.label!)\n $\(String(format: "%.2f", costValue))"
    }
    
    // Seçim kaldırıldığında tekrar eski metne dönme
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        chart2View.centerText = "" // Varsayılan ikonları geri getir
    }
    
    // Pie Chart Yüzde görünüm için
    class PercentFormatter: NSObject, ValueFormatter {
        func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
            return String(format: "%.1f%%", value) // 1 ondalık basamakla yüzde göster
        }
    }
    
    // 3. Grafik
    private func update3Chart(period: String, deviceUsages: [DeviceUsage]) {
        let deviceNames = ["AC", "Washer", "Combi", "AH", "Dishwasher", "Oven"]
        var consumptionData: [ChartDataEntry] = []
            
        for (index, deviceName) in deviceNames.enumerated() {
            let totalConsumption = deviceUsages.filter {
                normalizeDeviceName($0.deviceName ?? "") == deviceName
            }.reduce(0) { $0 + $1.electricityUsage + $1.gasUsage }
            consumptionData.append(ChartDataEntry(x: Double(index), y: totalConsumption))
        }
            
        let dataSet = LineChartDataSet(entries: consumptionData, label: "Total Energy Consumption")
        dataSet.colors = [NSUIColor.systemBlue] // Çizgi rengi
        dataSet.valueColors = [NSUIColor.black] // Değerlerin yazı rengi
        dataSet.mode = .cubicBezier // Çizgiyi yumuşat
        dataSet.lineWidth = 2.5
        //dataSet.drawCirclesEnabled = false // Veri noktalarında daire çizimini kapat
        dataSet.circleRadius = 6.0 // 📌 Noktaları belirgin hale getir
        dataSet.circleColors = [NSUIColor.systemBlue]
        dataSet.drawCirclesEnabled = true
        dataSet.drawFilledEnabled = true // 📌 Alt kısmı doldur (gradient efekt için)
        dataSet.fillAlpha = 0.4
        dataSet.drawValuesEnabled = false // Değerleri kaldırma

        // Gradyan renkleri ve yerleşimleri
        let gradientColors = [UIColor.systemBlue.cgColor, UIColor.clear.cgColor] as CFArray // Renkler
        let colorLocations: [CGFloat] = [1.0, 0.0] // Başlangıç ve bitiş noktaları
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)!

        // Gradyan dolgu
        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90.0) // Gradyanı ayarla
        dataSet.drawFilledEnabled = true // Alan doldurmayı etkinleştir

        let data = LineChartData(dataSet: dataSet)
        chart3View.data = data
        /*
            chart3View.xAxis.valueFormatter = IndexAxisValueFormatter(values: deviceNames)
            chart3View.notifyDataSetChanged()
            chart3View.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
            chart3View.xAxis.labelPosition = .bottom
            chart3View.xAxis.granularity = 1.0
         */
        // X Ekseni Ayarları
        let xAxis = chart3View.xAxis
        xAxis.drawGridLinesEnabled = false  // 📌 Izgara çizgilerini kaldır
        xAxis.drawAxisLineEnabled = false   // 📌 X eksenini kaldır
        xAxis.valueFormatter = IndexAxisValueFormatter(values: deviceNames)
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 12, weight: .bold)
        xAxis.granularity = 1
        xAxis.labelCount = deviceNames.count

        // Y Ekseni Ayarları
        let leftAxis = chart3View.leftAxis
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawLabelsEnabled = false

        let rightAxis = chart3View.rightAxis
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawLabelsEnabled = false

        chart3View.legend.enabled = false // 📌 Legend'ı kaldır (Gerekirse açabilirsin)
        chart3View.animate(xAxisDuration: 1.0)

        // Custom Marker
        let marker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: 60, height: 25))
        marker.chartView = chart3View
        chart3View.marker = marker
    }
    
    // 4. Grafik
    private func update4Chart(period: String, deviceUsages: [DeviceUsage]) {
        var electricityTotal = 0.0
            var waterTotal = 0.0
            var gasTotal = 0.0

            for usage in deviceUsages {
                electricityTotal += usage.electricityUsage
                waterTotal += usage.waterUsage
                gasTotal += usage.gasUsage
            }

            let entries = [
                BarChartDataEntry(x: 0, y: electricityTotal),
                BarChartDataEntry(x: 1, y: waterTotal),
                BarChartDataEntry(x: 2, y: gasTotal)
            ]

            let dataSet = BarChartDataSet(entries: entries, label: "Energy Consumption")
            dataSet.colors = ChartColorTemplates.joyful() // 📌 Joyful renkleri kullan
            dataSet.drawValuesEnabled = false

            let data = BarChartData(dataSet: dataSet)
            chart4View.data = data

            // 📌 X Ekseni Etiketlerini Sabit Başlat (Aynı Hizada Olacak)
            let xAxis = chart4View.xAxis
            xAxis.valueFormatter = IndexAxisValueFormatter(values: ["⚡ Electricity", "💧 Water", "🔥 Gas"])
            xAxis.labelPosition = .bottomInside
            xAxis.labelFont = .systemFont(ofSize: 14, weight: .bold)
            xAxis.yOffset = 10
            xAxis.drawGridLinesEnabled = false
            xAxis.drawAxisLineEnabled = false
            //xAxis.labelTextAlignment = .left

            // 📌 Y Ekseni Ayarları (Değişiklik yok)
            let leftAxis = chart4View.leftAxis
            leftAxis.drawGridLinesEnabled = false
            leftAxis.drawAxisLineEnabled = false
            leftAxis.drawLabelsEnabled = false

            let rightAxis = chart4View.rightAxis
            rightAxis.drawGridLinesEnabled = false
            rightAxis.drawAxisLineEnabled = false
            rightAxis.drawLabelsEnabled = false

            chart4View.legend.enabled = false
            chart4View.animate(yAxisDuration: 1.5)

            // 📌 Marker Eski Haline Geri Döndü
            let marker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: 80, height: 35))
            marker.chartView = chart4View
            chart4View.marker = marker
    }
    
    // 5. Grafik
    private func update5Chart(period: String, deviceUsages: [DeviceUsage]) {
        let deviceNames = ["AC", "Washer", "Combi", "AH", "Dishwasher", "Oven"]
        var costEntries: [BarChartDataEntry] = []
        var consumptionEntries: [ChartDataEntry] = []
        
        for (index, deviceName) in deviceNames.enumerated() {
            let totalCost = deviceUsages.filter {
                    normalizeDeviceName($0.deviceName ?? "") == deviceName
            }.reduce(0) { $0 + $1.totalCost }
            let totalConsumption = deviceUsages.filter {
                normalizeDeviceName($0.deviceName ?? "") == deviceName
            }.reduce(0) { $0 + $1.electricityUsage + $1.gasUsage}
            
            costEntries.append(BarChartDataEntry(x: Double(index), y: totalCost))
            consumptionEntries.append(ChartDataEntry(x: Double(index), y: totalConsumption))
        }
        
        /*
        let costDataSet = BarChartDataSet(entries: costEntries, label: "Cost ($)")
        let consumptionDataSet = LineChartDataSet(entries: consumptionEntries, label: "Consumption (kWh)")
        
        costDataSet.colors = [NSUIColor.red]
        consumptionDataSet.colors = [NSUIColor.blue]
        
        let data = CombinedChartData()
        data.barData = BarChartData(dataSet: costDataSet)
        data.lineData = LineChartData(dataSet: consumptionDataSet)
        
        chart5View.data = data
        chart5View.xAxis.valueFormatter = IndexAxisValueFormatter(values: deviceNames)
        chart5View.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
        chart5View.xAxis.labelPosition = .bottom // Etiket konumunu alt tarafa ayarla
        chart5View.xAxis.granularity = 1.0 // Her bir değer için bir etiket
         */
        
        // Bar Dataset (Maliyet)
        let costDataSet = BarChartDataSet(entries: costEntries, label: "Cost ($)")
        costDataSet.colors = [ChartColorTemplates.colorful()[2]]  // 📌 Bar rengi
        costDataSet.drawValuesEnabled = false // 📌 Bar üstüne değerleri koyma

        // Çizgi Dataset (Tüketim)
        let consumptionDataSet = LineChartDataSet(entries: consumptionEntries, label: "Consumption (kWh)")
        consumptionDataSet.colors = [ChartColorTemplates.joyful()[4]] // 📌 Çizgi rengi
        consumptionDataSet.lineWidth = 2.5
        consumptionDataSet.drawCirclesEnabled = true
        consumptionDataSet.circleRadius = 6.0
        consumptionDataSet.circleColors = [ChartColorTemplates.joyful()[4]] // 📌 Nokta rengi
        consumptionDataSet.mode = .cubicBezier // 📌 Çizgileri yumuşat
        consumptionDataSet.drawValuesEnabled = false // 📌 Çizgi üstüne değerleri koyma

        // Bar & Çizgi Grafiğini Kombine Et
        let data = CombinedChartData()
        data.barData = BarChartData(dataSet: costDataSet)
        data.lineData = LineChartData(dataSet: consumptionDataSet)

        chart5View.data = data

        // X Ekseni Ayarları (Gizle)
        let xAxis = chart5View.xAxis
        xAxis.drawGridLinesEnabled = false  // 📌 Izgara çizgilerini kaldır
        xAxis.drawAxisLineEnabled = false   // 📌 X eksenini kaldır
        xAxis.valueFormatter = IndexAxisValueFormatter(values: deviceNames)
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 12, weight: .bold)

        // Y Ekseni Ayarları (Gizle)
        let leftAxis = chart5View.leftAxis
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawLabelsEnabled = false

        let rightAxis = chart5View.rightAxis
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawLabelsEnabled = false

        chart5View.legend.enabled = false // 📌 Legend'ı kaldır (Gerekirse açabilirsin)
        chart5View.animate(xAxisDuration: 1.5)

        // CUSTOM MARKER EKLE (Tıklayınca Değeri Göster)
        let marker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
        marker.chartView = chart5View
        chart5View.marker = marker
    }
    
    // Bar Chart ve Line Chart'ın gösterge görünümü
    class CustomMarkerView: MarkerView {
        private var textLabel: UILabel!

        override init(frame: CGRect) {
            super.init(frame: frame)

            self.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            self.layer.cornerRadius = 8
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.clipsToBounds = true
            self.alpha = 0 // 📌 İlk başta gizli olacak

            // 📌 UILabel oluştur ve ekle
            textLabel = UILabel()
            textLabel.font = .systemFont(ofSize: 12, weight: .bold)
            textLabel.textColor = .black
            textLabel.textAlignment = .center
            textLabel.numberOfLines = 0  // 📌 Çok satırlı yazı desteği
            textLabel.lineBreakMode = .byWordWrapping // 📌 Kelime kaydırma aktif

            self.addSubview(textLabel)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
            let isBarChart = entry is BarChartDataEntry
            let valueType = isBarChart ? "Cost" : "Consumption" // 📌 Eğer Bar Chart ise Cost, değilse Consumption yaz

            textLabel.text = "\(valueType): \(String(format: "%.2f", entry.y))"

            // 📌 Marker'ın boyutunu yazıya göre ayarla
            let size = textLabel.sizeThatFits(CGSize(width: 120, height: CGFloat.greatestFiniteMagnitude))
            let width = max(size.width + 10, 80)
            let height = max(size.height + 10, 35)

            self.bounds = CGRect(x: 0, y: 0, width: width, height: height)
            textLabel.frame = CGRect(x: 5, y: 5, width: width - 10, height: height - 10)

            UIView.animate(withDuration: 0.2) {
                self.alpha = 1
            }
        }

        override func draw(context: CGContext, point: CGPoint) {
            super.draw(context: context, point: point)

            let offsetX = -self.bounds.size.width / 2
            let offsetY = -self.bounds.size.height - 10
            self.frame = CGRect(x: point.x + offsetX, y: point.y + offsetY, width: self.bounds.size.width, height: self.bounds.size.height)
        }
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
