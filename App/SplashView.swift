import SwiftUI

/// Animated brand splash — runs once per launch above the UI, then dissolves.
/// The static launch screen (LaunchBackground) matches this backdrop exactly.
struct SplashView: View {
    @Environment(AppState.self) private var state
    @State private var markShown = false
    @State private var wordShown = false
    @State private var dismissing = false

    var body: some View {
        ZStack {
            Palette.splashBack.ignoresSafeArea()

            RadialGradient(
                colors: [Palette.accent.opacity(0.16), .clear],
                center: .center, startRadius: 20, endRadius: 260
            )
            .frame(width: 420, height: 420)
            .scaleEffect(markShown ? 1 : 0.7)
            .blur(radius: 6)

            VStack(spacing: 10) {
                ZStack(alignment: .bottom) {
                    Text("L")
                        .font(.system(size: 128, weight: .semibold, design: .serif))
                        .foregroundStyle(Palette.accentGradient)
                    Swash(width: 58)
                        .offset(y: -12)
                }
                .offset(y: -6)

                VStack(spacing: 7) {
                    Text("Lexa")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Palette.ink)
                    Text("IELTS  VOCABULARY")
                        .font(.system(size: 10.5, weight: .semibold))
                        .tracking(5)
                        .foregroundStyle(Palette.muted)
                }
                .opacity(wordShown ? 1 : 0)
                .offset(y: wordShown ? 0 : 14)
            }
            .scaleEffect(markShown ? 1 : 0.86)
            .blur(radius: markShown ? 0 : 12)
            .opacity(markShown ? 1 : 0)
        }
        .opacity(dismissing ? 0 : 1)
        .scaleEffect(dismissing ? 1.05 : 1)
        .task { await play() }
        .onTapGesture { dismiss() }
    }

    private func play() async {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
            markShown = true
        }
        try? await Task.sleep(nanoseconds: 380_000_000)
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            wordShown = true
        }
        try? await Task.sleep(nanoseconds: 880_000_000)
        dismiss()
    }

    private func dismiss() {
        guard !dismissing else { return }
        withAnimation(.easeInOut(duration: 0.42)) {
            dismissing = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 430_000_000)
            withAnimation(.easeOut(duration: 0.2)) {
                state.splashDone = true
            }
        }
    }
}
