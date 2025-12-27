import SwiftUI

struct ClusterPinView: View {
    let color: Color
    let scoreText: String

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 34, height: 34)

                Text(scoreText)
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }

            Image(systemName: "triangle.fill")
                .font(.system(size: 12))
                .foregroundColor(color)
                .rotationEffect(.degrees(180))
                .offset(y: -3)
        }
        .shadow(radius: 6)
    }
}

