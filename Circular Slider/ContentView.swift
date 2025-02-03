//
//  ContentView.swift
//  Circular Slider
//
//  Created by Afeez Yunus on 01/02/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var temperature: Double = 180
    @State private var startAngle: Double = 0 // Starting angle for 3/4 circle
    @State private var endAngle: Double = 270   // End angle for 3/4 circle
    @State private var dragAngle: Double = 0
    private let borderMain = Color("borderMain")
    private let borderOrange = Color("borderOrange")
    private let borderYellow = Color.yellow
    private let borderPink = Color.pink
    @State private var isDragging: Bool = false
    
    private let presets = [100, 150, 180, 200, 220]
    
    var body: some View {
        VStack(spacing: 8) {
            VStack (alignment:.leading){
                HStack{
                    Image(systemName: "fan")
                    Text("Cooking mode")
                    Spacer()
                    Image(systemName: "chevron.down")
                        .frame(width: 32, height: 32)
                        .background(Color("borderOne"))
                        .clipShape(Circle())
                }
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(Color("textTertiary"))
                Text("Grill")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .contentTransition(.numericText())
                    .foregroundStyle(Color("textPrimary"))
               
            }
            .padding(16)
            .background(Color("bgSecondary"))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            .onAppear {
                dragAngle = temperature  // Direct assignment, no mapping needed
            }
            VStack(spacing: 24){
                HStack{
                    Image(systemName: "drop.degreesign.fill")
                    Text("Temperature")
                    Spacer()
                    Image(systemName: "chevron.down")
                        .frame(width: 32, height: 32)
                        .background(Color("borderOne"))
                        .clipShape(Circle())
                }
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(Color("textTertiary"))
                .padding(16)
                ZStack {
                    // Background track
                    Circle()
                        .trim(from: startAngle/360, to: endAngle/360)
                        .stroke(Color("borderOne"), style: .init(lineWidth:isDragging ? 30 : 20, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    
                    //large-ass dots
                    Circle()
                        .trim(from: startAngle/360, to: endAngle/360)
                        .stroke(Color("borderUpper2"), style: .init(lineWidth: 14, lineCap: .round, dash:[0.5, 81.6]))
                        .rotationEffect(.degrees(-90))
                    
                    // Active track
                    Circle()
                        .trim(from: startAngle/360, to: dragAngle/360)
                        .stroke(getColorForTemperature(temperature), style: .init(lineWidth: 20, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    //smaller dots
                    Circle()
                        .trim(from: startAngle/360, to: endAngle/360)
                        .stroke(Color("borderUpper"), style: .init(lineWidth: 4, lineCap: .round, dash:[0.5, 15.16]))
                        .rotationEffect(.degrees(-90))
                        .blendMode(.screen)
                    
                    // Temperature display
                    Text(temperature > 3 ? "\(Int(temperature))°C" : "Off")
                        .font(.system(size: 54, weight: .medium))
                        .contentTransition(.numericText())
                        .foregroundStyle(Color("textPrimary"))
                        .scaleEffect(isDragging ? 1.2 : 1)
                    
                    // Draggable handle
                    Circle()
                        .fill(Color("textPrimary"))
                        .stroke(Color("bgSecondary"), lineWidth: 7)
                        .frame(width: 28, height: 28)
                        .offset(y: -150) // Radius of the circle
                        .rotationEffect(.degrees(dragAngle))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let vector = CGVector(dx: value.location.x, dy: value.location.y)
                                    let rawAngle = atan2(vector.dy, vector.dx) * 180 / .pi + 90
                                    
                                    // Only update if within valid range (0-270)
                                    if rawAngle >= 0 && rawAngle <= 270 {
                                        withAnimation(.spring(duration:0.2)){
                                            isDragging = true
                                            dragAngle = rawAngle
                                            temperature = rawAngle
                                        }
                                    }
                                    // If outside range, don't update anything - handle stays at last valid position
                                }
                                .onEnded({ value in
                                    withAnimation(.spring(duration:0.2)){
                                        isDragging = false
                                    }
                                })
                        )
                }
                .frame(width: 300, height: 300)
                .padding(.vertical, 8)
                .onAppear {
                    dragAngle = temperature  // Direct assignment, no mapping needed
                }
                Rectangle()
                    .frame(height: 2)
                    .foregroundStyle(Color("bg"))
                VStack(spacing:12){
                    // Preset buttons
                    HStack(spacing: 8) {
                        ForEach(presets, id: \.self) { preset in
                            Button(action: {
                                withAnimation {
                                    temperature = Double(preset)
                                    dragAngle = temperature  // Direct assignment, no mapping needed
                                }
                            }) {
                                Text("\(preset)°")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .foregroundStyle(Color("textPrimary"))
                                    .fontWeight(.medium)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(16)
                            }
                        }
                    }
                    
                    // Plus/Minus buttons
                    HStack(spacing: 8) {
                        Button(action: {
                            withAnimation(.spring(duration:0.2)){
                                adjustTemperature(-10)
                            }
                        }) {
                            Text("-")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("borderOne"))
                                .foregroundStyle(Color("textPrimary"))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        Button(action: {
                            withAnimation(.spring(duration:0.2)){
                                adjustTemperature(10)
                            }
                        }) {
                            Text("+")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("borderOne"))
                                .foregroundStyle(Color("textPrimary"))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding( 8)
                }
            }
            .background(Color("bgSecondary"))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            // Cancel/Confirm buttons
          /*  HStack(spacing: 16) {
                Button("Confirm") {
                    // Handle confirm action
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundStyle(Color("bg"))
                .cornerRadius(16)
                .padding(.horizontal, 32)
            } */
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("bg"))
    }
    private func getColorForTemperature(_ temp: Double) -> Color {
          switch temp {
          case 135..<180:  // First third: Green to Orange
              return borderMain.interpolated(
                to: borderYellow,
                  fraction: temp / 90
              )
          case 180..<210:  // Second third: Orange to Yellow
              return borderYellow.interpolated(
                to: borderOrange,
                  fraction: (temp - 90) / 90
              )
          case 210...270:  // Final third: Yellow to Pink
              return borderOrange.interpolated(
                  to: borderPink,
                  fraction: (temp - 180) / 90
              )
          default:
              return borderMain
          }
      }
    private func adjustTemperature(_ change: Double) {
        let newTemp = temperature + change
        if newTemp >= 0 && newTemp <= 270 {
            temperature = newTemp
            dragAngle = temperature  // Direct assignment, no mapping needed
        }
    }
}



#Preview {
    ContentView()
}

extension Color {
    func interpolated(to other: Color, fraction: Double) -> Color {
        // Ensure fraction is between 0 and 1
        let fraction = min(max(fraction, 0), 1)
        
        // Convert colors to RGB components
        let component1 = UIColor(self).cgColor.components ?? [0, 0, 0, 0]
        let component2 = UIColor(other).cgColor.components ?? [0, 0, 0, 0]
        
        // Interpolate each component
        let r = component1[0] + (component2[0] - component1[0]) * fraction
        let g = component1[1] + (component2[1] - component1[1]) * fraction
        let b = component1[2] + (component2[2] - component1[2]) * fraction
        let a = component1[3] + (component2[3] - component1[3]) * fraction
        
        return Color(uiColor: UIColor(red: r, green: g, blue: b, alpha: a))
    }
}
