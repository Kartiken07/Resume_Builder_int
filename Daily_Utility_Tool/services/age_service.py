from datetime import datetime, timedelta
import pytz


class AgeService:

    @classmethod
    def calculate_age(cls, dob_str: str, target_str=None, timezone="UTC"):

        dob = cls._parse_date(dob_str)

        tz = pytz.timezone(timezone)
        today = datetime.now(tz).date()

        target_date = cls._parse_date(target_str) if target_str else today

        if dob > target_date:
            raise ValueError("DOB cannot be in future")

        years = target_date.year - dob.year
        months = target_date.month - dob.month
        days = target_date.day - dob.day

        if days < 0:
         months -= 1
         days += 30


        if months < 0:
            years -= 1
            months += 12

        next_birthday = dob.replace(year=target_date.year)
        if next_birthday < target_date:
            next_birthday = next_birthday.replace(year=target_date.year + 1)

        next_birthday_days = (next_birthday - target_date).days

        total_days = (target_date - dob).days
        total_weeks = total_days // 7
        total_hours = total_days * 24

        day_of_birth = dob.strftime("%A")

        zodiac = cls._get_zodiac(dob.month, dob.day)
        
        planetary_age = cls._calculate_planetary_age(total_days)

        working_days, weekends = cls._calculate_workdays(dob, target_date)

        life_expectancy = 80
        life_progress = round((years / life_expectancy) * 100, 2)

        historical_event = cls._get_historical_event(dob)
        famous_birthdays = cls._get_famous_birthdays(dob)

        return {
            "years": years,
            "months": months,
            "days": days,
            "next_birthday_days": next_birthday_days,
            "total_days": total_days,
            "total_weeks": total_weeks,
            "total_hours": total_hours,
            "day_of_birth": day_of_birth,
            "zodiac_sign": zodiac,
            "working_days": working_days,
            "weekends": weekends,
            "life_progress": life_progress,
            "historical_event": historical_event,
            "famous_birthdays": famous_birthdays,
            "planetary_age": planetary_age,
        }

    
    @staticmethod
    def _parse_date(date_str):
        if not date_str:
            return None

        formats = ["%Y-%m-%d", "%d-%m-%Y", "%d/%m/%Y"]

        for fmt in formats:
            try:
                return datetime.strptime(date_str, fmt).date()
            except:
                continue

        raise ValueError("Invalid date format")

  
    @staticmethod
    def _get_zodiac(month, day):
     if (month == 3 and day >= 21) or (month == 4 and day <= 19):
        return "Aries"
     elif (month == 4 and day >= 20) or (month == 5 and day <= 20):
        return "Taurus"
     elif (month == 5 and day >= 21) or (month == 6 and day <= 20):
        return "Gemini"
     elif (month == 6 and day >= 21) or (month == 7 and day <= 22):
        return "Cancer"
     elif (month == 7 and day >= 23) or (month == 8 and day <= 22):
        return "Leo"
     elif (month == 8 and day >= 23) or (month == 9 and day <= 22):
        return "Virgo"
     elif (month == 9 and day >= 23) or (month == 10 and day <= 22):
        return "Libra"
     elif (month == 10 and day >= 23) or (month == 11 and day <= 21):
        return "Scorpio"
     elif (month == 11 and day >= 22) or (month == 12 and day <= 21):
        return "Sagittarius"
     elif (month == 12 and day >= 22) or (month == 1 and day <= 19):
        return "Capricorn"
     elif (month == 1 and day >= 20) or (month == 2 and day <= 18):
        return "Aquarius"
     else:
        return "Pisces"

    
    @staticmethod
    def _calculate_workdays(start, end):
        working = 0
        weekend = 0

        current = start
        while current <= end:
            if current.weekday() < 5:
                working += 1
            else:
                weekend += 1
            current += timedelta(days=1)

        return working, weekend

    
    @staticmethod
    def _get_historical_event(dob):
     events = {
        # JANUARY
        "01-01": "New Year's Day celebrated worldwide",
        "09-01": "Pravasi Bharatiya Divas (India)",
        "12-01": "National Youth Day (India)",
        "15-01": "Indian Army Day",
        "26-01": "India Republic Day",
        "30-01": "Martyrs' Day (India)",

        # FEBRUARY
        "04-02": "World Cancer Day",
        "11-02": "International Day of Women and Girls in Science",
        "14-02": "Valentine's Day",
        "28-02": "National Science Day (India)",

        # MARCH
        "08-03": "International Women's Day",
        "15-03": "World Consumer Rights Day",
        "20-03": "International Day of Happiness",
        "21-03": "World Poetry Day",
        "22-03": "World Water Day",
        "23-03": "Shaheed Diwas (Bhagat Singh)",

        # APRIL
        "01-04": "April Fool's Day",
        "07-04": "World Health Day",
        "14-04": "Ambedkar Jayanti",
        "18-04": "World Heritage Day",
        "22-04": "Earth Day",
        "23-04": "World Book Day",

        # MAY
        "01-05": "Labour Day",
        "03-05": "World Press Freedom Day",
        "08-05": "World Red Cross Day",
        "11-05": "National Technology Day (India)",
        "15-05": "International Day of Families",
        "31-05": "World No Tobacco Day",

        # JUNE
        "05-06": "World Environment Day",
        "08-06": "World Oceans Day",
        "14-06": "World Blood Donor Day",
        "21-06": "International Yoga Day",

        # JULY
        "01-07": "National Doctors' Day (India)",
        "11-07": "World Population Day",
        "26-07": "Kargil Vijay Diwas",

        # AUGUST
        "06-08": "Hiroshima Day",
        "09-08": "Quit India Movement Day",
        "12-08": "International Youth Day",
        "15-08": "India Independence Day",
        "29-08": "National Sports Day (India)",

        # SEPTEMBER
        "05-09": "Teacher's Day (India)",
        "08-09": "International Literacy Day",
        "15-09": "Engineers' Day (India)",
        "16-09": "World Ozone Day",
        "27-09": "World Tourism Day",

        # OCTOBER
        "02-10": "Gandhi Jayanti",
        "05-10": "World Teachers' Day",
        "10-10": "World Mental Health Day",
        "16-10": "World Food Day",
        "24-10": "United Nations Day",
        "31-10": "National Unity Day (India)",

        # NOVEMBER
        "07-11": "National Cancer Awareness Day (India)",
        "14-11": "Children's Day (India)",
        "19-11": "International Men's Day",
        "26-11": "Constitution Day (India)",

        # DECEMBER
        "01-12": "World AIDS Day",
        "10-12": "Human Rights Day",
        "23-12": "Kisan Diwas (India)",
        "25-12": "Christmas Day",
        
    }
     
     return events.get(dob.strftime("%d-%m"), "No major event found")
 
    
    @staticmethod
    def _calculate_planetary_age(total_days):
        earth_years = total_days / 365.25

        planets = {
            "Mercury": 0.24,
            "Venus": 0.62,
            "Earth": 1.00,
            "Mars": 1.88,
            "Jupiter": 11.86,
            "Saturn": 29.46,
            "Uranus": 84.01,
            "Neptune": 164.8
        }

        planetary_age = {}

        for planet, period in planets.items():
            planetary_age[planet] = round(earth_years / period, 2)

        return planetary_age

    
    @staticmethod
    def _get_famous_birthdays(dob):
     famous = {
        # JANUARY
        "01-01": {"entertainers": [], "athletes": [], "politicians": [], "business": [], "authors": ["J. D. Salinger"]},
        "07-01": {"entertainers": ["Nicolas Cage"], "athletes": [], "politicians": [], "business": [], "authors": []},
        "10-01": {"entertainers": ["Hrithik Roshan"], "athletes": [], "politicians": [], "business": [], "authors": []},
        "15-01": {"entertainers": [], "athletes": [], "politicians": ["Martin Luther King Jr."], "business": [], "authors": []},
        "17-01": {"entertainers": [], "athletes": [], "politicians": [], "business": ["Mukesh Ambani"], "authors": []},

        # FEBRUARY
        "05-02": {"entertainers": ["Cristiano Ronaldo"], "athletes": ["Cristiano Ronaldo"], "politicians": [], "business": [], "authors": []},
        "11-02": {"entertainers": ["Jennifer Aniston"], "athletes": [], "politicians": [], "business": [], "authors": []},
        "18-02": {"entertainers": [], "athletes": [], "politicians": [], "business": ["Michael Dell"], "authors": []},
        "24-02": {"entertainers": [], "athletes": ["Sachin Tendulkar"], "politicians": [], "business": [], "authors": []},

        # MARCH
        "03-03": {"entertainers": ["Shraddha Kapoor"], "athletes": [], "politicians": [], "business": [], "authors": []},
        "14-03": {"entertainers": ["Aamir Khan"], "athletes": [], "politicians": [], "business": [], "authors": []},
        "15-03": {"entertainers": ["Alia Bhatt"], "athletes": [], "politicians": [], "business": [], "authors": []},
        "26-03": {"entertainers": [], "athletes": [], "politicians": [], "business": ["Larry Page"], "authors": []},

        # APRIL
        "07-04": {"entertainers": ["Jackie Chan"], "athletes": [], "politicians": [], "business": [], "authors": []},
        "15-04": {"entertainers": ["Emma Watson"], "athletes": [], "politicians": [], "business": [], "authors": []},
        "20-04": {"entertainers": [], "athletes": [], "politicians": [], "business": [], "authors": ["William Shakespeare"]},
        "21-04": {"entertainers": [], "athletes": [], "politicians": [], "business": [], "authors": ["Charlotte Brontë"]},
        "24-04": {"entertainers": [], "athletes": ["Sachin Tendulkar"], "politicians": [], "business": [], "authors": []},

        # MAY
        "07-05": {"entertainers": [], "athletes": [], "politicians": ["Rabindranath Tagore"], "business": [], "authors": []},
        "15-05": {"entertainers": ["Madhuri Dixit"], "athletes": [], "politicians": [], "business": [], "authors": []},
        "31-05": {"entertainers": [], "athletes": [], "politicians": [], "business": [], "authors": ["Walt Whitman"]},

        # JUNE
        "05-06": {"entertainers": ["Mark Wahlberg"], "athletes": [], "politicians": [], "business": [], "authors": []},
        "14-06": {"entertainers": [], "athletes": [], "politicians": ["Donald Trump"], "business": [], "authors": []},
        "21-06": {"entertainers": ["Chris Pratt"], "athletes": [], "politicians": [], "business": [], "authors": []},

        # JULY
        "05-07": {"entertainers": [], "athletes": ["MS Dhoni"], "politicians": [], "business": [], "authors": []},
        "06-07": {"entertainers": ["Ranveer Singh"], "athletes": [], "politicians": [], "business": [], "authors": []},
        "18-07": {"entertainers": ["Priyanka Chopra"], "athletes": [], "politicians": [], "business": [], "authors": []},

        # AUGUST
        "05-08": {"entertainers": [], "athletes": [], "politicians": [], "business": ["Sundar Pichai"], "authors": []},
        "15-08": {"entertainers": [], "athletes": [], "politicians": [], "business": [], "authors": ["Napoleon Bonaparte"]},
        "28-08": {"entertainers": ["Shania Twain"], "athletes": [], "politicians": [], "business": [], "authors": []},

        # SEPTEMBER
        "05-09": {"entertainers": [], "athletes": [], "politicians": ["Dr. S. Radhakrishnan"], "business": [], "authors": []},
        "16-09": {"entertainers": [], "athletes": [], "politicians": [], "business": [], "authors": ["Agatha Christie"]},
        "28-09": {"entertainers": ["Ranbir Kapoor"], "athletes": [], "politicians": [], "business": [], "authors": []},

        # OCTOBER
        "02-10": {"entertainers": [], "athletes": [], "politicians": ["Mahatma Gandhi"], "business": [], "authors": []},
        "16-10": {"entertainers": [], "athletes": [], "politicians": [], "business": ["Elon Musk"], "authors": []},
        "28-10": {"entertainers": [], "athletes": [], "politicians": [], "business": ["Bill Gates"], "authors": []},

        # NOVEMBER
        "05-11": {"entertainers": [], "athletes": ["Virat Kohli"], "politicians": [], "business": [], "authors": []},
        "19-11": {"entertainers": [], "athletes": [], "politicians": ["Indira Gandhi"], "business": [], "authors": []},

        # DECEMBER
        "13-12": {"entertainers": ["Taylor Swift"], "athletes": [], "politicians": [], "business": [], "authors": []},
        "18-12": {"entertainers": ["Brad Pitt"], "athletes": [], "politicians": [], "business": [], "authors": []},
        "25-12": {"entertainers": [], "athletes": [], "politicians": [], "business": [], "authors": ["Isaac Newton"]},
        "27-12": {"entertainers": ["Salman Khan"], "athletes": [], "politicians": [], "business": [], "authors": []}
    }
     return famous.get(dob.strftime("%d-%m"), {
        "entertainers": [],
        "athletes": [],
        "politicians": [],
        "business": [],
        "authors": []
    })
