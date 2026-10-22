import SSCore

/// Coach silhouettes on the 200 x 200 mascot grid, extracted from design/mascots.
/// The pen traces these when it draws a coach.
enum CoachOutlines {
    struct Outline {
        let body: String
        let extras: [String]
    }

    static func outline(for coach: Coach) -> Outline {
        switch coach {
        case .pebble:
            Outline(body: "M36 150 C28 110 62 72 105 73 C150 74 174 108 167 147 C162 172 122 176 100 176 C70 176 42 171 36 150 Z",
                    extras: [])
        case .fern:
            Outline(body: "M58 166 C46 134 62 100 100 100 C138 100 154 134 142 166 C135 179 65 179 58 166 Z",
                    extras: [])
        case .wren:
            Outline(body: "M48 128 C48 96 74 80 102 80 C132 80 156 100 156 130 C156 158 132 174 102 174 C72 174 48 158 48 128 Z",
                    extras: [])
        case .bramble:
            Outline(body: "M46 142 C46 104 70 82 100 82 C130 82 154 104 154 142 C154 167 132 176 100 176 C68 176 46 167 46 142 Z",
                    extras: ["M49 92 a18 18 0 1 1 36 0 a18 18 0 1 1 -36 0 Z", "M115 92 a18 18 0 1 1 36 0 a18 18 0 1 1 -36 0 Z"])
        case .luna:
            Outline(body: "M51 128 a49 49 0 1 1 98 0 a49 49 0 1 1 -98 0 Z",
                    extras: [])
        case .otto:
            Outline(body: "M54 150 C50 112 72 86 100 86 C128 86 150 112 146 150 C144 170 126 177 100 177 C74 177 56 170 54 150 Z",
                    extras: ["M136 160 C158 166 179 158 189 141 C179 147 160 151 140 146 Z", "M59 99 a11 11 0 1 1 22 0 a11 11 0 1 1 -22 0 Z", "M119 99 a11 11 0 1 1 22 0 a11 11 0 1 1 -22 0 Z"])
        case .miso:
            Outline(body: "M44 144 C44 108 68 86 100 86 C132 86 156 108 156 144 C156 168 134 177 100 177 C66 177 44 168 44 144 Z",
                    extras: ["M56 106 C55 90 58 76 63 67 C66 62 70 62 73 65 C80 72 88 80 95 89 Z",
                             "M144 106 C145 90 142 76 137 67 C134 62 130 62 127 65 C120 72 112 80 105 89 Z",
                             "M146 164 C166 168 182 158 185 140 C186 129 179 122 172 126 C176 133 176 143 168 149 C160 155 151 155 142 153 Z"])
        case .tilly:
            Outline(body: "M34 160 C34 114 62 94 100 94 C138 94 166 114 166 160 Z",
                    extras: [])
        }
    }
}
