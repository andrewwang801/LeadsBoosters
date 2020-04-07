//
//  Region.swift
//  project
//
//  Created by Apple Developer on 2020/1/27.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import SwiftyJSON

class Schedule {

    var id = 0
    var firstTeamName = ""
    var secondTeamName = ""
    var date = ""
    var week = 0
    var team1Score = ""
    var team2Score = ""
    var result = ""
    
    init(_ firstTeamName: String, _ secondTeamName: String, _ date: String,  _ week: Int, _ id: Int, _ team1Score: String, _ team2Score: String) {
        self.firstTeamName = firstTeamName
        self.secondTeamName = secondTeamName
        self.date = date
        self.id = id
        self.week = week
        self.team1Score = team1Score
        self.team2Score = team2Score
        if team1Score != "" && team2Score != "" {
            self.result = team1Score + ":" + team2Score
        }
        else {
            self.result = ""
        }
    }
    
    static func fromToArr(json: JSON) -> [Schedule] {
        
        var scheduleArr: [Schedule] = []
        for schedule in json.arrayValue {
            let _firstTeamName = schedule["team1"].string ?? ""
            let _secondTeamName = schedule["team2"].string ?? ""
            let _week = schedule["week"].int ?? 0
            let _date = schedule["date"].string ?? ""
            let _id = schedule["id"].int ?? 0
            let _team1Score = schedule["team1_score"].string ?? ""
            let _team2Score = schedule["team2_score"].string ?? ""
            let schedule = Schedule(_firstTeamName, _secondTeamName, _date, _week, _id, _team1Score, _team2Score)
            scheduleArr.append(schedule)
        }
        return scheduleArr
    }
}
