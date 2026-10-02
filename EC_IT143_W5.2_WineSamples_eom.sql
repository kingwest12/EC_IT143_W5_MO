/*
    File:        EC_IT143_W5.2_WineSamples_eom.sql
    Author:      Ebenezer Owusu Manu
    Course:      EC IT 143
    Assignment:  5.2 Final Project: My Communities Analysis - Create Answers
    Community:   Wine Samples (UCI Wine Quality)
    Database:    MyCommunities
    Created:     2026-10-02

    Purpose:
    Answer four wine-sample questions with readable T-SQL queries. The
    questions and author credits below are taken from the student's 4.4
    question workbook.

    Final-submission note:
    The assignment requires at least one question in this script to be authored
    by another student. Replace one selected question and its author credit
    after adding a peer-authored question from the 4.3 Collaboration Corner.
*/

USE [MyCommunities];
GO

/*
    Question 5:
    How do average quality scores and sample counts compare between red and
    white wines?

    Original question author: Ebenezer Owusu Manu
    Stakeholder perspective: Wine quality coordinator

    Answer:
    Join sample measurements to quality scores, then summarize by wine type.
*/
SELECT
    s.WineType,
    COUNT(DISTINCT q.SampleID) AS sample_count,
    CAST(AVG(CAST(q.Quality AS DECIMAL(5, 2))) AS DECIMAL(5, 2))
        AS average_quality
FROM dbo.WineSamples AS s
INNER JOIN dbo.WineQuality AS q
    ON q.SampleID = s.SampleID
GROUP BY
    s.WineType
ORDER BY
    s.WineType;
GO

/*
    Question 6:
    Within each wine type, are higher alcohol measurements associated with
    higher average quality ratings?

    Original question author: Ebenezer Owusu Manu
    Stakeholder perspective: Wine research analyst

    Answer:
    Group alcohol measurements to one decimal place within each wine type.
    The average quality and sample count make the trend easier to compare.
*/
;WITH WineQualityByAlcohol AS
(
    SELECT
        s.SampleID,
        s.WineType,
        CAST(ROUND(s.Alcohol, 1) AS DECIMAL(4, 1)) AS alcohol_percent,
        q.Quality
    FROM dbo.WineSamples AS s
    INNER JOIN dbo.WineQuality AS q
        ON q.SampleID = s.SampleID
)
SELECT
    WineType,
    alcohol_percent,
    COUNT(DISTINCT SampleID) AS sample_count,
    CAST(AVG(CAST(Quality AS DECIMAL(5, 2))) AS DECIMAL(5, 2))
        AS average_quality
FROM WineQualityByAlcohol
GROUP BY
    WineType,
    alcohol_percent
ORDER BY
    WineType,
    alcohol_percent;
GO

/*
    Question 7:
    Which samples have the highest quality score within each wine type, and
    what measurements describe them?

    Original question author: Ebenezer Owusu Mnu
    Stakeholder perspective: Wine product developer

    Answer:
    Rank samples within each wine type. DENSE_RANK returns all samples tied
    for the highest quality score for that type.
*/
;WITH RankedWineSamples AS
(
    SELECT
        s.SampleID,
        s.WineType,
        q.Quality,
        s.FixedAcidity,
        s.VolatileAcidity,
        s.ResidualSugar,
        s.Alcohol,
        DENSE_RANK() OVER
        (
            PARTITION BY s.WineType
            ORDER BY q.Quality DESC
        ) AS quality_rank
    FROM dbo.WineSamples AS s
    INNER JOIN dbo.WineQuality AS q
        ON q.SampleID = s.SampleID
)
SELECT
    SampleID,
    WineType,
    Quality,
    FixedAcidity,
    VolatileAcidity,
    ResidualSugar,
    Alcohol
FROM RankedWineSamples
WHERE quality_rank = 1
ORDER BY
    WineType,
    SampleID;
GO

/*
    Question 8:
    For each wine type, how many samples have a quality score of 7 or higher,
    and what is their average alcohol content?

    Original question author: Ebenezer Owusu Mnu
    Stakeholder perspective: Winery analyst

    Answer:
    Conditional aggregation counts only samples rated 7 or higher and averages
    alcohol only for those same samples.
*/
SELECT
    s.WineType,
    COUNT(DISTINCT CASE
        WHEN q.Quality >= 7 THEN s.SampleID
    END) AS high_quality_sample_count,
    CAST(AVG(CASE
        WHEN q.Quality >= 7 THEN CAST(s.Alcohol AS DECIMAL(5, 2))
    END) AS DECIMAL(5, 2)) AS average_alcohol
FROM dbo.WineSamples AS s
INNER JOIN dbo.WineQuality AS q
    ON q.SampleID = s.SampleID
GROUP BY
    s.WineType
ORDER BY
    s.WineType;
GO
