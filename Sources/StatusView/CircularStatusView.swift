//
//  CircularProgressView.swift
//  SwiftUITest
//
//  Created by Stefan Klieme on 19.07.22.
//

import Combine
import SwiftUI

public struct CircularStatusView: View {
    
    fileprivate struct Arc: InsettableShape {
        var progress: Double
        var insetAmount = 0.0
        
        func path(in rect: CGRect) -> Path {
            return Path { path in
                path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                            radius: rect.width / 2 - insetAmount,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(360.0 * progress - 90.0),
                            clockwise: false)
                
            }
        }
        
        func inset(by amount: CGFloat) -> some InsettableShape {
            var arc = self
            arc.insetAmount += amount
            return arc
        }
    }
    
    public enum Appearance { case normal, inverted }
    
    public enum StatusIcon : Equatable {
        case failed(Appearance = .normal)
        case failedDisabled(Appearance = .normal)
        case caution(Appearance = .normal)
        case cautionDisabled(Appearance = .normal)
        case success(Appearance = .normal)
        case successDisabled(Appearance = .normal)
        case completed(Appearance = .normal)
        case completedDisabled(Appearance = .normal)
    }
    
    public enum Status : Equatable {
        case none, indeterminate, progress(CGFloat), icon(StatusIcon)
    }
    
    public let size : CGFloat
    public var status: Status
    public var color : Color
    public var showPercentage : Bool
    
    public init(size: CGFloat, status: Status = .none, color: Color = .blue, showPercentage: Bool = false) {
        self.size = size
        self.status = status
        self.color = color
        self.showPercentage = showPercentage
    }
    
    @State private var degrees = 0
    
    public var body: some View {
        let lineWidth = size / 10.0
        ZStack {
            switch status {
                case .none:
                    EmptyView()
                    
                case .indeterminate:
                    // EmptyView()
                    IndeterminateView(lineWidth: lineWidth, color: color)
                    
                case .progress(let degrees):
                    Arc(progress: 1.0)
                        .strokeBorder(.gray, lineWidth: lineWidth)
                        .opacity(0.2)
                    
                    Arc(progress: degrees)
                        .strokeBorder(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .miter))
                    if showPercentage {
                        Text("\(Int(degrees * 100))%")
                            .font(.system(size: size / 3.4))
                    }
                    
                case .icon(.failed(let appearance)):
                    let imageName = appearance == .inverted ? "xmark.circle": "xmark.circle.fill"
                    statusImage(name: imageName, color: .red)
                    
                case .icon(.failedDisabled(let appearance)):
                    let imageName = appearance == .inverted ? "xmark.circle": "xmark.circle.fill"
                    statusImage(name: imageName, color: .gray.opacity(0.5))
                    
                case .icon(.caution(let appearance)):
                    let imageName = appearance == .inverted ? "exclamationmark.circle" : "exclamationmark.circle.fill"
                    statusImage(name: imageName, color: .orange)
                    
                case .icon(.cautionDisabled(let appearance)):
                    let imageName = appearance == .inverted ? "exclamationmark.circle" : "exclamationmark.circle.fill"
                    statusImage(name: imageName, color: .gray.opacity(0.5))
                    
                case .icon(.success(let appearance)):
                    let imageName = appearance == .inverted ? "checkmark.circle": "checkmark.circle.fill"
                    statusImage(name: imageName, color: .green)
                    
                case .icon(.successDisabled(let appearance)), .icon(.completedDisabled(let appearance)):
                    let imageName = appearance == .inverted ? "checkmark.circle": "checkmark.circle.fill"
                    statusImage(name: imageName, color: .gray.opacity(0.5))

                    
                case .icon(.completed(let appearance)):
                    let imageName = appearance == .inverted ? "checkmark.circle": "checkmark.circle.fill"
                    statusImage(name: imageName, color: color)
                    
            }
        }
        .frame(width: size, height: size)
        .animation(.easeInOut, value: status)
    }
    
    private func statusImage(name: String, color: Color) -> some View {
        Image(systemName: name)
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
    }
}

private struct IndeterminateView : View {
    
    @StateObject private var timerManager = TimerManager()
    @State private var degrees = 0
    
    let lineWidth : CGFloat
    let color : Color
    
    var body: some View {
        Group {
            CircularStatusView.Arc(progress: 0.7)
                .strokeBorder(color, lineWidth: lineWidth)
                .rotationEffect(Angle(degrees: Double(degrees)))
        }
        .onReceive(timerManager.makeTimerPublisher()) { _ in
                let newValue = self.degrees + 6
                self.degrees = newValue == 360 ? 0 : newValue
        }
        .animation(degrees == 350 ? .easeInOut : nil, value: degrees)
        .onDisappear { timerManager.stop() }
    }
        
}

private class TimerManager: ObservableObject {
    var cancellables = Set<AnyCancellable>()
    
    func makeTimerPublisher() -> some Publisher<Date, Never> {
        let timerPublisher = Timer.publish(every: 0.03, on: .main, in: .default)
        timerPublisher.connect().store(in: &cancellables)
        return timerPublisher
    }
    
    func stop() {
        cancellables.removeAll()
    }
}


struct CircularProgressView_Previews: PreviewProvider {
   
    static var previews: some View {
        let size = 64.0
        VStack {
            Group {
                HStack {
                    CircularStatusView(size: size, status: .none)
                    CircularStatusView(size: size, status: .progress(0.65))
                    CircularStatusView(size: size, status: .indeterminate, color: .red)
                    CircularStatusView(size: size, status: .progress(1.0), color: .yellow, showPercentage: true)
                }
                HStack {
                    CircularStatusView(size: size, status: .icon(.success()))
                    CircularStatusView(size: size, status: .icon(.successDisabled()))
                    CircularStatusView(size: size, status: .icon(.success(.inverted)))
                    CircularStatusView(size: size, status: .icon(.successDisabled(.inverted)))
                }
                HStack {
                    CircularStatusView(size: size, status: .icon(.failed()))
                    CircularStatusView(size: size, status: .icon(.failedDisabled()))
                    CircularStatusView(size: size, status: .icon(.failed(.inverted)))
                    CircularStatusView(size: size, status: .icon(.failedDisabled(.inverted)))
                }
                HStack {
                    CircularStatusView(size: size, status: .icon(.caution()))
                    CircularStatusView(size: size, status: .icon(.cautionDisabled()))
                    CircularStatusView(size: size, status: .icon(.caution(.inverted)))
                    CircularStatusView(size: size, status: .icon(.cautionDisabled(.inverted)))
                }
                HStack {
                    CircularStatusView(size: size, status: .icon(.completed()))
                    CircularStatusView(size: size, status: .icon(.completedDisabled()))
                    CircularStatusView(size: size, status: .icon(.completed(.inverted)))
                    CircularStatusView(size: size, status: .icon(.completedDisabled(.inverted)))
                }
            }
        }
    }
}
