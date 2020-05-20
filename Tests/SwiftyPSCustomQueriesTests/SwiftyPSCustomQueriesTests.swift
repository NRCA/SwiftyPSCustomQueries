//
//    SwiftyPSCustomQueriesTests.swift
//
//    Copyright (c) 2020 Doug Penny – North Raleigh Christian Academy
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import XCTest
@testable import SwiftyPSCore
@testable import SwiftyPSCustomQueries

class PowerQueryTests: XCTestCase {
    static var allTests = [
        ("testHomeroomRosterForTeacher", testHomeroomRosterForTeacher),
        ("testSectionsForCourseNumber", testSectionsForCourseNumber),
        ("testTeacherSections", testTeacherSections)
    ]

    var client: SwiftyPSCore!
    var params: TestingParameters!

    override func setUp() {
        super.setUp()
        print("PowerQueryTests setup called--")
        /**
         This is a temporary workaround becuase Swift packages do not currently support resources. This will be
         resolved in Swift 5.3: https://github.com/apple/swift-evolution/blob/master/proposals/0271-package-manager-resources.md
         
         The following 4 lines can be replaced with the following single line of code:
         if let paramFilePath = Bundle(for: type(of: self)).path(forResource: "testing_parameters", ofType: "json")
         */
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        let paramFileURL = thisDirectory.appendingPathComponent("testing_parameters.json")
        if paramFileURL != URL(fileURLWithPath: "") {
            let decoder = JSONDecoder()
            do {
                let paramData = try Data(contentsOf: paramFileURL)
                self.params = try decoder.decode(TestingParameters.self, from: paramData)
                self.client = SwiftyPSCore(self.params.baseURL,
                                                clientID: self.params.clientID,
                                                clientSecret: self.params.clientSecret)
            } catch let parseError {
                XCTFail("Failed to decode JSON parameters file.\nError: \(parseError.localizedDescription)")
            }
        } else {
            print("File not found!")
        }
    }

    func testHomeroomRosterForTeacher() {
        if let testTeacher = self.params.testTeacher {
            let teacherHomeroomRosterExpectation = self.expectation(description: "get homeroom roster")

            client.homeroomRosterForTeacher(testTeacher.dcid) { homeroomRoster, error in
                if let homeroomRoster = homeroomRoster {
                    if let testHomeroomRoster = testTeacher.homeroomRoster {
                        XCTAssertEqual(testHomeroomRoster[0].gradeLevel, homeroomRoster[0].gradeLevel)
                        XCTAssertEqual(testHomeroomRoster[0].lastFirst, homeroomRoster[0].lastFirst)
                        XCTAssertEqual(testHomeroomRoster[1].studentNumber, homeroomRoster[1].studentNumber)
                        XCTAssertEqual(testHomeroomRoster[1].gender, homeroomRoster[1].gender)
                        teacherHomeroomRosterExpectation.fulfill()
                    } else {
                        XCTFail(error?.localizedDescription ?? "There was no test homeroom roster defined.")
                    }
                } else {
                    XCTFail(error?.localizedDescription ?? "An error occured retreiving the teacher's homeroom roster.")
                }
            }

            self.waitForExpectations(timeout: 1) { error in
                if let error = error {
                    XCTFail(error.localizedDescription)
                }
            }
        } else {
            XCTFail("No test teacher found.")
        }
    }

    func testSectionsForCourseNumber() {
        if let testCourse = self.params.testCourse {
            let courseSectionsExpectation = self.expectation(description: "get sections for course number")

            client.sectionsForCourseNumber(testCourse.courseNumber) { courseSections, error in
                if let courseSections = courseSections {
                    if let testCourseSections = testCourse.courseSections {
                        XCTAssertEqual(testCourseSections[0].courseNumber, courseSections[0].courseNumber)
                        XCTAssertEqual(testCourseSections[0].courseName, courseSections[0].courseName)
                        XCTAssertEqual(testCourseSections[0].period, courseSections[0].period)
                        XCTAssertEqual(testCourseSections[0].room, courseSections[0].room)
                        XCTAssertEqual(testCourseSections[0].numStudents, courseSections[0].numStudents)
                        XCTAssertEqual(testCourseSections[0].id, courseSections[0].id)
                        XCTAssertEqual(testCourseSections[0].teacherID, courseSections[0].teacherID)
                        XCTAssertEqual(testCourseSections[0].dcid, courseSections[0].dcid)
                        XCTAssertEqual(testCourseSections[0].sectionNumber, courseSections[0].sectionNumber)
                        courseSectionsExpectation.fulfill()
                    } else {
                        XCTFail(error?.localizedDescription ?? "There were no test sections defined.")
                    }
                } else {
                    XCTFail(error?.localizedDescription ?? "An error occured retreiving the course sections.")
                }
            }

            self.waitForExpectations(timeout: 1) { error in
                if let error = error {
                    XCTFail(error.localizedDescription)
                }
            }
        } else {
            XCTFail("No test course found.")
        }
    }

    func testTeacherSections() {
        if let testTeacher = self.params.testTeacher {
            let teacherSectionsExpectation = self.expectation(description: "get teacher sections")

            client.sectionsForTeacher(testTeacher.teacherID) { teacherSections, error in
                if let teacherSections = teacherSections {
                    if let testTeacherSections = testTeacher.teacherSections {
                        XCTAssertEqual(testTeacherSections[0].courseNumber, teacherSections[0].courseNumber)
                        XCTAssertEqual(testTeacherSections[0].courseName, teacherSections[0].courseName)
                        XCTAssertEqual(testTeacherSections[0].period, teacherSections[0].period)
                        XCTAssertEqual(testTeacherSections[0].room, teacherSections[0].room)
                        XCTAssertEqual(testTeacherSections[0].numStudents, teacherSections[0].numStudents)
                        XCTAssertEqual(testTeacherSections[0].id, teacherSections[0].id)
                        XCTAssertEqual(testTeacherSections[0].teacherID, teacherSections[0].teacherID)
                        XCTAssertEqual(testTeacherSections[0].dcid, teacherSections[0].dcid)
                        XCTAssertEqual(testTeacherSections[0].sectionNumber, teacherSections[0].sectionNumber)
                        teacherSectionsExpectation.fulfill()
                    } else {
                        XCTFail(error?.localizedDescription ?? "There were no test sections defined.")
                    }
                } else {
                    XCTFail(error?.localizedDescription ?? "An error occured retreiving the teacher's sections.")
                }
            }

            self.waitForExpectations(timeout: 1) { error in
                if let error = error {
                    XCTFail(error.localizedDescription)
                }
            }
        } else {
            XCTFail("No test teacher found.")
        }
    }
}
