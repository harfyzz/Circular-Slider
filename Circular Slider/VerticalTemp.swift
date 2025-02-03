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
    var body: some View {
        
        GeometryReader{ geometry in
            HStack{
                VStack{
                    slider.view()
                }
                
                .onAppear {
                    viewHeight = geometry.size.height
                }
                .onChange(of: isTemperatureActive, { oldValue, newValue in
                    if isTemperatureActive {
                        let riveValue = (temperature / 270) * 100
                        slider.setInput("value", value: riveValue)
                    } else {
                        let riveValue = humidity
                        slider.setInput("value", value: riveValue)
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
                .frame(maxWidth: .infinity)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                temperature = eventValue
            }
        }
    }
}
