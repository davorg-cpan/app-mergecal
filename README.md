# App::MergeCal

A program to merge iCal files into a single calendar.

    $ mergecal some_file.json

Where `some_file.json` looks like this:

    {
      "title": "My Combined Calendar",
      "output": "combined.ics",
      "calendars": [
        "calendar1.ics",
        "calendar2.ics",
        "calendar3.ics"
      ]
    }
