//
//  StaggerSlider.swift
//  Circular Slider
//
//  Created by Afeez Yunus on 02/02/2025.
//

import SwiftUI

struct StaggerSlider: View {
    @State private var sliderValue: Double = 32
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            CustomSlider(value: $sliderValue, range: 0...100)
                .padding(.horizontal, 40)
        }
    }
}

#Preview {
    StaggerSlider()
}

struct CustomSlider: View {
    @Binding var value: Double
    @State var isDragging: Bool = false
    @State var rotationAngle: Double = 0  // Track rotation angle
    @State var lastDragValue: CGFloat = 0 // Track last drag position
    @State var dragVelocity: CGFloat = 0
    let range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(height: 4)
                
                // Active track
                Rectangle()
                    .foregroundColor(.white)
                    .frame(width: self.getSliderPosition(width: geometry.size.width), height: 4)
                
                // Thumb with value label
                VStack(spacing:4){
                    Text("\(Int(value))")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .padding(.horizontal,8)
                        .padding(.vertical,4)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .offset(y: isDragging ? -10 : 10)
                        .opacity(isDragging ? 1 : 0)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(.spring,
                                   value: rotationAngle)
                    Circle()
                        .fill(Color("bg"))
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 20, height: 20)
                }
                .position(x: self.getSliderPosition(width: geometry.size.width), y: 1)
                .gesture(
                    DragGesture(minimumDistance: 1)
                        .onChanged { gesture in
                            withAnimation(.spring(duration:0.2)){
                                isDragging = true
                            }
                            // Calculate drag velocity
                            let currentPosition = gesture.location.x
                            let dragDelta = currentPosition - lastDragValue
                            dragVelocity = dragDelta
                            
                            // Update rotation based on velocity
                            // Clamp rotation to reasonable values
                            rotationAngle = -dragVelocity * 1
                            rotationAngle = max(-60, min(60, rotationAngle))
                            
                            lastDragValue = currentPosition
                            self.updateValue(width: geometry.size.width,
                                             dragLocation: gesture.location.x)
                        }
                        .onEnded({ value in
                            withAnimation(.spring(duration:0.2)){
                                isDragging = false
                                rotationAngle = 0
                            }
                            dragVelocity = 0
                            lastDragValue = 0
                        })
                )
                .offset(y: -8)
            }
        }
        .frame(height: 20)
    }
    
    private func getSliderPosition(width: CGFloat) -> CGFloat {
        let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return max(10, min(width - 10, width * CGFloat(percent)))
    }
    
    private func updateValue(width: CGFloat, dragLocation: CGFloat) {
        let newPercent = max(0, min(1, dragLocation / width))
        let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(newPercent)
        value = newValue
    }
}
