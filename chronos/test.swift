//import Foundation
//let math = Block(time: Time(minute: 0, hour: 12), duration: Time(minute: 0, hour: 4), completionDuration: Time(), name: "math", rigid: false, priority: 2, status: "not attempted")
//let reading = Block(time: Time(minute: 0, hour: 16), duration: Time(minute: 0, hour: 4), completionDuration: Time(), name: "reading", rigid: false, priority: 2, status: "not attempted")
//let swim = Block(time: Time(minute: 0, hour: 20), duration: Time(minute: 0, hour: 4), completionDuration:Time(), name: "swim", rigid: false, priority: 2, status: "not attempted")
//
//var schedule = [math, reading, swim]
//
//func calcTime(currentTime: Int) {
//  print(schedule) //  prints the original schedule for comparison
//  let timeLeft = 24 - currentTime // the amount of time left to spend on activities
//  var totalTime = 0 // original sum of the activity times
//  var totalPriority = 0 // sum of the priority values
//  var indexOfFirst = 100 // index of the first "yet to be done" element of schedule
//  var counter = 0 //  # of "yet to be done" activities
//  for index in schedule.indices{
//    if schedule[index].status != "completed"{
//      totalTime = totalTime + schedule[index].duration // sums the original durations
//      totalPriority = totalPriority + schedule[index].priority
//      counter = counter + 1
//    }
//  }
//  for index in schedule.indices{
//    if schedule[index].status != "completed"{
//       schedule[index].duration = (schedule[index].duration * timeLeft / totalTime) * (schedule[index].priority * counter / totalPriority) // caculates the new durations
//    }
//  }
//
//  for index in schedule.indices{
//    if schedule[index].status != "completed"{
//       if index < indexOfFirst{
//         indexOfFirst = index // finds the index of the first "yet to be done" element of schedule
//       }
//    }
//  }
//
//  for index in schedule.indices{
//    if schedule[index].status != "completed"{
//      if index == indexOfFirst{
//        schedule[indexOfFirst].time = currentTime // adjusts the starting times
//      }
//      else{
//        schedule[index].time = schedule[index - 1].time + schedule[index - 1].duration // adjusts the starting times
//      }
//    }
//  }
//  print(schedule) // prints final schedule for comparison
//}

//calcTime(currentTime: 16)// figure out main.swift
// let currentDate = Date()
// let date = Date()
// let calendar = Calendar.current
// let hour = calendar.component(.hour, from: date)
 // let minutes = calendar.component(.minute, from: date)
