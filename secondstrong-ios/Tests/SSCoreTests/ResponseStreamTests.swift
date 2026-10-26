import Testing
@testable import SSCore

@Suite struct ResponseStreamTests {
    @Test func aPlainReplyThinksThenWrites() {
        #expect(ResponsePlan.stages(photo: false).map(\.stage) == [.thinking, .writing])
    }

    @Test func aPhotoIsReadSpottedAndEstimatedBeforeItWrites() {
        let plan = ResponsePlan.stages(photo: true)
        #expect(plan.map(\.stage) == [.thinking, .reading, .spotting, .estimating, .writing])
        #expect(plan.last?.seconds == 0)
    }

    @Test func everyStageHasAShortPlainLabel() {
        for stage in ResponseStage.allCases {
            #expect(!stage.label.isEmpty && stage.label.count <= 26 && !stage.label.contains("!"), "\(stage)")
        }
        #expect(ResponseStage.estimating.label == "Estimating portions")
    }

    @Test func revealGrowsSmoothlyAndNeverOvershoots() {
        let total = 120
        var last = -1.0
        for step in 0...80 {
            let shown = TokenStream.revealed(total: total, elapsed: Double(step) * 0.05)
            #expect(shown >= last && shown <= Double(total))
            #expect(shown - last < 4, "no jumps: \(shown - last)")
            last = shown
        }
        #expect(TokenStream.revealed(total: total, elapsed: 100) == Double(total))
        #expect(TokenStream.revealed(total: total, elapsed: 0) == 0)
    }

    @Test func theDurationMatchesTheRevealRate() {
        let total = 120
        let end = TokenStream.duration(total: total)
        #expect(TokenStream.revealed(total: total, elapsed: end) == Double(total))
        #expect(TokenStream.revealed(total: total, elapsed: end - 0.1) < Double(total))
        #expect(end > 1 && end < 6)
        #expect(TokenStream.duration(total: 0) == 0)
    }

    @Test func aCutOffAnswerEndsOnAWholeWord() {
        #expect(TokenStream.wholeWords("Try eggs on toast with cottage ch") == "Try eggs on toast with cottage")
        #expect(TokenStream.wholeWords("Try eggs on ") == "Try eggs on")
        #expect(TokenStream.wholeWords("Hello") == "")
        #expect(TokenStream.wholeWords("") == "")
    }

    @Test func fastSpeedFinishesAtOnce() {
        #expect(TokenStream.revealed(total: 50, elapsed: 0.01, speed: 1e9) == 50)
    }
}

@Suite struct ResponseOutcomeTests {
    @Test func failuresAreCalmAndBlameNoOne() {
        for failure in ResponseFailure.allCases {
            let text = failure.message.lowercased()
            #expect(!text.contains("error") && !text.contains("!") && !text.contains("sorry") && !text.contains("you "), "\(text)")
            #expect(failure.message.count <= 60 && !failure.retryLabel.isEmpty)
        }
    }

    @Test func eachFailureSaysWhatToDo() {
        #expect(ResponseFailure.network.retryLabel == "Try again")
        #expect(ResponseFailure.photo.message.contains("photo"))
        #expect(ResponseFailure.network.message.contains("Nothing was lost"))
    }

    @Test func aStoppedAnswerKeepsWhatArrived() {
        #expect(ResponseOutcome.stopped.keepsPartialText && ResponseOutcome.failed(.network).keepsPartialText)
        #expect(ResponseOutcome.stopped.note == "Stopped")
        #expect(ResponseOutcome.completed.note == nil)
    }
}
