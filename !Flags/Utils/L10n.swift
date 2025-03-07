import Foundation

enum L10n {
    enum Continent {
        static let europe = "continent.europe"
        static let asia = "continent.asia"
        static let northAmerica = "continent.north_america"
        static let southAmerica = "continent.south_america"
        static let africa = "continent.africa"
        static let oceania = "continent.oceania"
        static let antarctica = "continent.antarctica"
        
        static let countryCount = "continent.country_count"
    }
    
    enum Achievement {
        static let livingAtlasTitle = "achievement.living_atlas.title"
        static let livingAtlasDescription = "achievement.living_atlas.description"
        
        static let geographyWitcherTitle = "achievement.geography_witcher.title"
        static let geographyWitcherDescription = "achievement.geography_witcher.description"
        
        static let travelerTitle = "achievement.traveler.title"
        static let travelerDescription = "achievement.traveler.description"
        
        static let seaConquerorTitle = "achievement.sea_conqueror.title"
        static let seaConquerorDescription = "achievement.sea_conqueror.description"
        
        static let cartographySherlockTitle = "achievement.cartography_sherlock.title"
        static let cartographySherlockDescription = "achievement.cartography_sherlock.description"
        
        static let alienTouristTitle = "achievement.alien_tourist.title"
        static let alienTouristDescription = "achievement.alien_tourist.description"
        
        static let dailyChallengeTitle = "achievement.daily_challenge.title"
        static let dailyChallengeDescription = "achievement.daily_challenge.description"
    }
    
    enum Profile {
        static let level = "profile.level"
        static let guest = "profile.guest"
        enum Level {
            static let newbie = "profile.level.newbie"
            static let explorer = "profile.level.explorer"
            static let expert = "profile.level.expert"
            static let master = "profile.level.master"
            static let guru = "profile.level.guru"
        }
        
        enum Progress {
            static let start = "profile.progress.start"
            static let first10 = "profile.progress.first_10"
            static let first50 = "profile.progress.first_50"
            static let first100 = "profile.progress.first_100"
            static let almostAll = "profile.progress.almost_all"
            static let completed = "profile.progress.completed"
            static let defaultProgress = "profile.progress.default"
        }
        
        enum Milestone {
            static let to10 = "profile.milestone.to_10"
            static let to25 = "profile.milestone.to_25"
            static let to50 = "profile.milestone.to_50"
            static let to100 = "profile.milestone.to_100"
            static let toComplete = "profile.milestone.to_complete"
        }
    }
    
    enum Common {
        static let countries = "common.countries"
        static let country = "common.country"
        static let cancel = "common.cancel"
        static let done = "common.done"
        static let error = "common.error"
        static let ok = "common.ok"
    }
}

// MARK: - String Extension
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized(_ args: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: args)
    }
} 