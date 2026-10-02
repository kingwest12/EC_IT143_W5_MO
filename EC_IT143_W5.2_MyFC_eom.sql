/*
    File:        EC_IT143_W5.2_MyFC_eom.sql
    Author:      Ebenezer Owusu Manu
    Course:      EC IT 143
    Assignment:  5.2 Final Project: My Communities Analysis - Create Answers
    Community:   Soccer Players (MyFC)
    Database:    MyCommunities
    Created:     2026-10-02

    Purpose:
    Answer four MyFC questions with readable T-SQL queries. The questions and
    author credits below are taken from the student's 4.4 question workbook.

    Final-submission note:
    The assignment requires at least one question in this script to be authored
    by another student. Replace one selected question and its author credit
    after adding a peer-authored question from the 4.3 Collaboration Corner.
*/

USE [MyCommunities];
GO

/*
    Question 1:
    Which players have the highest month-to-date salary, and on which record
    dates were those amounts reported?

    Original question author: Ebenezer Owusu Manu
    Stakeholder perspective: MyFC payroll analyst

    Answer:
    Return the highest salary record(s) for each as_of_date. DENSE_RANK keeps
    every player tied for the highest salary on a reporting date.
*/
;WITH RankedPlayerSalary AS
(
    SELECT
        d.pl_id,
        d.pl_name,
        d.t_id,
        d.p_id,
        f.as_of_date,
        f.mtd_salary,
        DENSE_RANK() OVER
        (
            PARTITION BY f.as_of_date
            ORDER BY f.mtd_salary DESC
        ) AS salary_rank
    FROM dbo.tblPlayerDim AS d
    INNER JOIN dbo.tblPlayerFact AS f
        ON f.pl_id = d.pl_id
)
SELECT
    as_of_date,
    pl_id,
    pl_name,
    t_id,
    p_id,
    mtd_salary
FROM RankedPlayerSalary
WHERE salary_rank = 1
ORDER BY as_of_date, pl_name;
GO

/*
    Question 2:
    How many players are listed for each team on each reporting date?

    Original question author: Ebenezer Owusu Manu
    Stakeholder perspective: MyFC team manager

    Answer:
    Count distinct players with a fact record for each team and reporting date.
*/
SELECT
    d.t_id,
    f.as_of_date,
    COUNT(DISTINCT d.pl_id) AS player_count
FROM dbo.tblPlayerDim AS d
INNER JOIN dbo.tblPlayerFact AS f
    ON f.pl_id = d.pl_id
GROUP BY
    d.t_id,
    f.as_of_date
ORDER BY
    f.as_of_date,
    d.t_id;
GO

/*
    Question 3:
    Which player records have no matching salary fact, and what team and
    position are they associated with?

    Original question author: Ebenezer Owusu Manu
    Stakeholder perspective: MyFC roster administrator

    Answer:
    A LEFT JOIN preserves every player record; a NULL fact-side player ID
    identifies a player with no matching salary fact.
*/
SELECT
    d.pl_id,
    d.pl_name,
    d.pl_num,
    d.t_id,
    d.p_id
FROM dbo.tblPlayerDim AS d
LEFT JOIN dbo.tblPlayerFact AS f
    ON f.pl_id = d.pl_id
WHERE f.pl_id IS NULL
ORDER BY
    d.t_id,
    d.p_id,
    d.pl_name;
GO

/*
    Question 4:
    What is the total month-to-date salary for each team on each as_of_date?

    Original question author: Ebenezer Owusu Manu
    Stakeholder perspective: MyFC budget analyst

    Answer:
    Sum the salary fact values after linking each player to the player's team.
*/
SELECT
    d.t_id,
    f.as_of_date,
    SUM(f.mtd_salary) AS total_mtd_salary
FROM dbo.tblPlayerDim AS d
INNER JOIN dbo.tblPlayerFact AS f
    ON f.pl_id = d.pl_id
GROUP BY
    d.t_id,
    f.as_of_date
ORDER BY
    f.as_of_date,
    d.t_id;
GO
