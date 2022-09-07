class HistoricAppointmentsController < PublicFacingController
  before_action :load_role, except: [:past_chancellors]
  helper_method :previous_appointments_with_unique_people, :previous_appointments_list

  def index
    @recent_appointments = individual_role_appointees(all_recent_appointments)
    @twentieth_century_appointments = individual_role_appointees(all_twentieth_century_appointments)
    @eighteenth_and_nineteenth_century_appointments = individual_role_appointees(all_historical_appointments)
  end

  def past_chancellors
    @twentyfirst_century_chancellors = {
      "Nadhim Zahawi" => {
        service: "2022",
      },
      "Rishi Sunak" => {
        service: "2020 to 2022",
      },
      "Sajid Javid" => {
        service: "2019 to 2020",
      },
      "Philip Hammond" => {
        service: "2016 to 2019",
      },
      "George Osborne" => {
        service: "2010 to 2016",
      },
      "Alistair Darling" => {
        service: "2007 to 2010",
      },
      "Gordon Brown" => {
        service: "1997 to 2007",
      },
    }

    @twentieth_century_chancellors = {
      "Kenneth Clarke" => {
        service: "1993 to 1997",
      },
      "Norman Lamont" => {
        service: "1990 to 1993",
      },
      "John Major" => {
        service: "1989 to 1990",
      },
      "Nigel Lawson" => {
        service: "1983 to 1989",
      },
      "Sir Geoffrey Howe" => {
        service: "1979 to 1983",
      },
      "Denis Healey" => {
        service: "1974 to 1979",
      },
      "Anthony Barber" => {
        service: "1970 to 1974",
      },
      "Ian Macleod" => {
        service: "1970",
      },
      "Roy Jenkins" => {
        service: "1967 to 1970",
      },
      "James Callaghan" => {
        service: "1964 to 1967",
      },
      "Reginald Maudling" => {
        service: "1962 to 1964",
      },
      "Selwyn Lloyd" => {
        service: "1960 to 1962",
      },
      "Derick Heathcoat-Amory" => {
        service: "1958 to 1960",
      },
      "Peter Thorneycroft" => {
        service: "1957 to 1958",
      },
      "Harold Macmilla" => {
        service: "1955 to 1957",
      },
      "Rab Butler" => {
        service: "1951 to 1955",
      },
      "Hugh Gaitskell" => {
        service: "1950 to 1951",
      },
      "Sir Stafford Cripps" => {
        service: "1947 to 1950",
      },
      "Hugh Dalton" => {
        service: "1945 to 1947",
      },
      "Sir John Anderson" => {
        service: "1943 to 1945",
      },
      "Sir Kingsley Wood" => {
        service: "1940 to 1943",
      },
      "Sir John Simon" => {
        service: "1937 to 1940",
      },
      "Neville Chamberlain" => {
        service: ["1931 to 1937", "1923 to 1924"],
      },
      "Philip Snowden" => {
        service: ["1929 to 1931", "1924"],
      },
      "Winston Churchill" => {
        service: "1924 to 1929",
      },
      "Stanley Baldwin" => {
        service: "1922 to 1923",
      },
      "Sir Robert Horne" => {
        service: "1921 to 1922",
      },
      "Austen Chamberlain" => {
        service: ["1919 to 1921", "1903 to 1905"],
      },
      "Bonar Law" => {
        service: ["1916 to 1919"],
      },
      "Reginald McKenna" => {
        service: "1915 to 1916",
      },
      "David Lloyd George" => {
        service: ["1908 to 1915"],
      },
      "H. H. Asquith" => {
        service: ["1905 to 1908"],
      },
      "Charles Ritchie" => {
        service: ["1902 to 1903"],
      },
    }

    @nineteenth_century_chancellors = {
      "Sir Michael Hicks Beach, Bt" => {
        service: ["1895 to 1902", "1885 to 1886"],
      },
      "Sir William Vernon Harcourt" => {
        service: ["1892 to 1895", "1886"],
      },
      "George Goschen" => {
        service: ["1887 to 1892"],
      },
      "Lord Randolph Churchill" => {
        service: "1886",
      },
      "Hugh Childers" => {
        service: "1882 to 1885",
      },
      "William Gladstone" => {
        service: ["1880 to 1882", "1873 to 1874", "1859 to 1866", "1852 to 1855"],
      },
      "Sir Stafford Henry Northcote, Bt" => {
        service: "1874 to 1880",
      },
      "Robert Lowe" => {
        service: "1868 to 1873",
      },
      "George Ward Hunt" => {
        service: "1868",
      },
      "Benjamin Disraeli" => {
        service: ["1866 to 1868", "1858 to 1859", "1852"],
      },
      "Sir George Cornewall Lewis, Bt" => {
        service: "1855 to 1858",
      },
      "Sir Charles Wood" => {
        service: "1846 to 1852",
      },
      "Henry Goulburn" => {
        service: ["1841 to 1846", "1828 to 1830"],
      },
      "Francis Baring" => {
        service: "1839 to 1841",
      },
      "Thomas Spring Rice" => {
        service: "1835 to 1839",
      },
      "Sir Robert Peel, Bt" => {
        service: "1834 to 1835",
      },
      "Thomas Denman, 1st Baron Denman" => {
        service: "1834",
      },
      "Viscount Althorp" => {
        service: "1830 to 1834",
      },
      "John Charles Herries" => {
        service: "1827 to 1828",
      },
      "The Lord Tenterden" => {
        service: "1827",
      },
      "George Canning" => {
        service: "1827",
      },
      "Hon. Frederick John Robinson" => {
        service: "1823 to 1827",
      },
      "Nicholas Vansittart" => {
        service: "1812 to 1823",
      },
      "Spencer Perceval" => {
        service: "1807 to 1812",
      },
      "Lord Henry Petty" => {
        service: "1806 to 1807",
      },
      "Edward Law, 1st Baron Ellenborough" => {
        service: "1806",
      },
      "William Pitt the Younge" => {
        service: ["1804 to 1806", "1783 to 1801", "1782 to 1783"],
      },
      "Henry Addington" => {
        service: "1801 to 1804",
      },
    }

    @eighteenth_century_chancellors = {
      "Lord John Cavendish" => {
        service: "1783",
      },
      "Lord North" => {
        service: "1767 to 1782",
      },
      "Charles Townshend" => {
        service: "1766 to 1767",
      },
      "William Dowdeswell" => {
        service: "1765 to 1766",
      },
      "George Grenville" => {
        service: "1763 to 1765",
      },
      "Sir Francis Dashwood" => {
        service: "1762 to 1763",
      },
      "Viscount Barrington" => {
        service: "1761 to 1762",
      },
      "Henry Bilson Legge" => {
        service: ["1757 to 1761", "1756 to 1757", "1754 to 1755"],
      },
      "Lord Mansfield" => {
        service: "1757",
      },
      "Sir George Lyttleton" => {
        service: "1755 to 1756",
      },
      "Sir William Lee" => {
        service: "1754",
      },
      "Henry Pelham" => {
        service: "1743 to 1754",
      },
      "Samuel Sandys" => {
        service: "1742 to 1743",
      },
      "Sir Robert Walpole" => {
        service: ["1721 to 1742", "1715 to 1717"],
      },
      "Sir John Pratt" => {
        service: "1721",
      },
      "John Aislabie" => {
        service: "1718 to 1721",
      },
      "Viscount Stanhope" => {
        service: "1717 to 1718",
      },
      "Sir Richard Onslow" => {
        service: "1714 to 1715",
      },
      "Sir William Wyndhan" => {
        service: "1713 to 1714",
      },
      "Robert Benson" => {
        service: "1711 to 1713",
      },
      "Robert Harley" => {
        service: "1710 to 1711",
      },
      "Sir John Smith" => {
        service: ["1708 to 1710", "1699 to 1701"],
      },
      "Henry Boyle" => {
        service: "1701 to 1708",
      },
    }

    @sixteenth_and_seventeenth_century_chancellors = {
      "Charles Montagu" => {
        service: "1694 to 1699",
      },
      "Richard Hampden" => {
        service: "1690 to 1694",
      },
      "Henry Booth" => {
        service: "1689 to 1690",
      },
      "Sir John Ernle" => {
        service: "1676 to 1689",
      },
      "Sir John Duncombe" => {
        service: "1672 to 1676",
      },
      "Lord Ashley" => {
        service: "1661 to 1672",
      },
      "Sir Edward Hyde" => {
        service: "1643 to 1646",
      },
      "Sir John Colepepper" => {
        service: "1642 to 1643",
      },
      "Lord Cottington" => {
        service: "1629 to 1642",
      },
      "Lord Barrett" => {
        service: "1628 to 1629",
      },
      "Sir Richard Weston" => {
        service: "1621 to 1628",
      },
      "Sir Fulke Greville" => {
        service: "1614 to 1621",
      },
      "Sir Julius Caesar" => {
        service: "1606 to 1614",
      },
      "Earl of Dunbar" => {
        service: "1603 to 1606",
      },
      "Sir John Fortescue" => {
        service: "1589 to 1603",
      },
      "Sir Walter Mildmay" => {
        service: "1566 to 1589",
      },
      "Sir Richard Sackville" => {
        service: "1559 to 1566",
      },
    }
  end

  def show
    @person = PersonPresenter.new(Person.friendly.find(params[:person_id]), view_context)
    @historical_account = @person.historical_accounts.for_role(@role).first
    raise(ActiveRecord::RecordNotFound, "Couldn't find HistoricalAccount for #{@person.inspect}  and #{@role.inspect}") unless @historical_account
  end

private

  def all_recent_appointments
    present_roles(previous_appointments.where("started_at > ?", Date.civil(2001)))
  end

  def all_twentieth_century_appointments
    present_roles(previous_appointments.between(Date.civil(1901), Date.civil(2000)))
  end

  def all_historical_appointments
    present_roles(previous_appointments.between(Date.civil(1701), Date.civil(1900)))
  end

  def present_roles(roles)
    roles.map { |r| RoleAppointmentPresenter.new(r, view_context) }
  end

  def load_role
    @role = Role.friendly.find(role_id)
  end

  def role_id
    Role::HISTORIC_ROLE_PARAM_MAPPINGS[params[:role]]
  end

  def previous_appointments
    @previous_appointments ||= @role.previous_appointments.includes(:role, person: :historical_accounts).reorder("started_at DESC")
  end

  def previous_appointments_with_unique_people
    previous_appointments.distinct(&:person)
  end

  def individual_role_appointees(appointments)
    appointments.uniq { |appointment| appointment.person.id }
  end

  def previous_appointments_list
    {
      "links" => {
        "ordered_related_items" => previous_appointments_with_unique_people.map do |role_appointment|
          {
            "title" => role_appointment.person.name,
            "base_path" => role_appointment.has_historical_account? ? "/government/history/#{@role.historic_param}/#{role_appointment.person.slug}" : "/government/history/#{@role.historic_param}",
          }
        end,
      },
    }
  end
end
