//
//  VerticalTemp.swift
//  Circular Slider
//
//  Created by Afeez Yunus on 02/02/2025.
//

import SwiftUI
import RiveRuntime

struct VerticalTemp: View {
    @StateObject var slider = VerticalSlider()
    @State var temperature: Double = 0
    @State private var dragOffset: CGFloat = 0
    @State private var viewHeight: CGFloat = 0
    @State private var lastTemperature: Double = 0
    @State var isTemperatureActive: Bool = true
    @State var humidity: Double = 0
    @State var lastHumidity: Double = 0
    var valueText = RiveViewModel(fileName: "valuetext", stateMachineName: "State Machine 1")
    var body: some View {
        
        GeometryReader{ geometry in
            ZStack(alignment:.leading){
                HStack{
                    Spacer()
                    VStack(alignment:.trailing, spacing:32){
                        Spacer()
                        VStack(alignment:.trailing, spacing:8){
                            HStack{
                                Image(systemName: "humidity.fill")
                                Text("Humidity")
                            }
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color("textTertiary"))
                            Text(humidity > 3 ? "\(Int(humidity))%" : "Off")
                                .animation(.spring(duration: 0.2))
                                .contentTransition(.numericText())
                                .foregroundStyle(isTemperatureActive ? Color("textTertiary") : Color.white)
                                .font(.system(size: 48, weight: .semibold, design :.monospaced ))
                        }
                        .background(Color("bg"))
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.2)){
                                isTemperatureActive = false
                            }
                        }
                        VStack(alignment:.trailing, spacing:8){
                            HStack{
                                Image(systemName: "drop.degreesign.fill")
                                Text("Temperature")
                            }
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color("textTertiary"))
                            Text(temperature > 3 ? "\(Int(temperature))°C" : "Off")
                                .animation(.spring(duration: 0.2))
                                .contentTransition(.numericText())
                                .foregroundStyle(!isTemperatureActive ? Color("textTertiary") : Color.white)
                                .font(.system(size: 48, weight: .semibold, design :.monospaced ))
                        }
                        .background(Color("bg"))
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.2)){
                                isTemperatureActive = true
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
                HStack{
                    VStack{
                        slider.view()
                    }
                        .frame(width:150 )
                    .onAppear {
                        viewHeight = geometry.size.height
                    }
                    .onChange(of: isTemperatureActive, { oldValue, newValue in
                        if isTemperatureActive {
                            let riveValue = (temperature / 270) * 100
                            slider.setInput("value", value: riveValue)
                            do {
                                try valueText.setTextRunValue("Value", textValue: "\(Int(temperature))°")
                            } catch {
                                print ("Cannot set text value")
                            }
                        } else {
                            let riveValue = humidity
                            slider.setInput("value", value: riveValue)
                            do {
                                try valueText.setTextRunValue("Value", textValue:"\(Int(humidity))%")
                            } catch {
                                print ("Cannot set text value")
                            }
                        }
                    })
                    .padding(.vertical, 32)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if isTemperatureActive {
                                    if slider.temperature {
                                        slider.setInput("isActive?", value: true)
                                        dragOffset = -value.translation.height
                                        
                                        // Calculate new temperature based on drag and last temperature
                                        let dragHeight = dragOffset / viewHeight
                                        let rawTemp = lastTemperature + (dragHeight * 270)
                                        temperature = min(max(rawTemp, 0), 270)
                                        
                                        // Convert to Rive animation range (0-100)
                                        let riveValue = (temperature / 270) * 100
                                        slider.setInput("value", value: riveValue)
                                        do {
                                            try valueText.setTextRunValue("Value", textValue: "\(Int(temperature))°" )
                                        } catch {
                                            print ("Cannot set text value")
                                        }
                                    }
                                } else {
                                    if slider.temperature {
                                        slider.setInput("isActive?", value: true)
                                        dragOffset = -value.translation.height
                                        
                                        // Calculate new temperature based on drag and last temperature
                                        let dragHeight = dragOffset / viewHeight
                                        let rawHumidity = lastHumidity + (dragHeight * 100)
                                        humidity = min(max(rawHumidity, 0), 100)
                                        
                                        // Convert to Rive animation range (0-100)
                                        slider.setInput("value", value: humidity)
                                        do {
                                            try valueText.setTextRunValue("Value", textValue: "\(Int(humidity))%" )
                                        } catch {
                                            print ("Cannot set text value")
                                        }
                                    }
                                }
                                
                                
                            }
                            .onEnded { _ in
                                if isTemperatureActive {
                                    lastTemperature = temperature
                                } else {
                                    lastHumidity = humidity  // Added this line
                                }
                                dragOffset = 0
                                slider.setInput("isActive?", value: false)
                            }
                    )
                /*    if slider.temperature{
                        //label text
                        valueText.view()
                            .frame(height: 30)
                            .position(
                                x: isTemperatureActive ? 10 : 0,
                                       y: {
                                           let rawPosition = isTemperatureActive ?
                                               (viewHeight - 100) - ((temperature / 270) * (viewHeight - 100)) :
                                               (viewHeight - 100) - ((humidity / 100) * (viewHeight - 100))
                                           
                                           // Add padding of ~20-30 pixels from top and bottom
                                           let topPadding: CGFloat = 48
                                           let bottomPadding: CGFloat = 85
                                           
                                           return min(
                                               max(rawPosition, topPadding),
                                               viewHeight - bottomPadding
                                           )
                                       }()
                                   )
                                   .animation(.spring(), value: temperature)
                                   .animation(.spring(), value: humidity)
                            
                    } */
                            
                    Spacer()
                }
               
            }
            .padding(.horizontal, 16)
            .background(Color("bg"))
        }
    }
}

#Preview {
    VerticalTemp()
}


class VerticalSlider: RiveViewModel {
    @Published var temperature = false
    
    init() {
        super.init(fileName: "vertical_temperature", stateMachineName: "main")
    }
    
    func view() -> some View {
        super.view()
    }
    // Subscribe to Rive events
    @objc func onRiveEventReceived(onRiveEvent riveEvent: RiveEvent) {
        if let generalEvent = riveEvent as? RiveGeneralEvent {
            let eventProperties = generalEvent.properties()
            
            if let eventValue = eventProperties["isActive?"] as? Bool {
                withAnimation(.spring(duration:0.2)) {
                    temperature = eventValue
                }
            }
        }
    }
}
