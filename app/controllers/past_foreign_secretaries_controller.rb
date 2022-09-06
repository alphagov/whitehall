class PastForeignSecretariesController < PublicFacingController
  layout "frontend"

  def index
    @twenty_first_century = {
      "Elizabeth Truss" => {
        service: "2021 to 2022",
      },
      "Dominic Raab" => {
        service: "2019 to 2021",
      },
      "Jeremy Hunt" => {
        service: "2018 to 2019",
      },
      "Boris Johnson" => {
        service: "2016 to 2018",
      },
      "Philip Hammond" => {
        service: "2014 to 2016",
      },
      "William Hague" => {
        service: "2010 to 2014",
      },
      "David Miliband" => {
        service: "2007 to 2010",
      },
      "Margaret Beckett" => {
        service: "2006 to 2007",
      },
      "Jack Straw" => {
        service: "2001 to 2006",
      },
    }

    @twentieth_century = {
      "Robin Cook" => {
        service: "1997 to 2001",
      },
      "Sir Malcolm Rifkind" => {
        service: "1995 to 1997",
      },
      "Douglas Hurd, Lord Hurd of Westwell" => {
        service: "1989 to 1995",
      },
      "Sir John Major" => {
        service: "1989",
      },
      "Sir Geoffrey Howe, Lord Howe of Aberavon" => {
        service: "1983 to 1989",
      },
      "Francis Pym, Lord Pym of Sandy" => {
        service: "1982 to 1983",
      },
      "Lord Peter Carrington, Baron Carrington" => {
        service: "1979 to 1982",
      },
      "Dr David Owen, Lord Owen of the City of Plymouth" => {
        service: "1977 to 1979",
      },
      "Anthony Crosland" => {
        service: "1976 to 1977",
      },
      "James Callaghan, Lord Callaghan of Cardiff" => {
        service: "1974 to 1976",
      },
      "Sir Alec Douglas-Home, Lord Home of the Hirsel" => {
        service: ["1970 to 1974", "1960 to 1963"],
      },
      "Michael Stewart, Lord Stewart of Fulham" => {
        service: ["1968 to 1970", "1965 to 1966"],
      },
      "George Brown, Lord George-Brown of Jevington" => {
        service: "1966 to 1968",
      },
      "Patrick Gordon Walker" => {
        service: "1964 to 1965",
      },
      "Richard Austen Butler, Lord Butler of Saffron Walden" => {
        service: "1963 to 1964",
      },
      "John Selwyn Brooke Lloyd, Lord Selwyn-Lloyd" => {
        service: "1955 to 1960",
      },
      "Harold Macmillan, Earl of Stockton" => {
        service: "1955",
      },
      "Sir Anthony Eden, Earl of Avon" => {
        service: ["1951 to 1955", "1940 to 1945", "1935 to 1938"],
      },
      "Herbert Morrison, Lord Morrison of Lambeth" => {
        service: "1951",
      },
      "Ernest Bevin" => {
        service: "1945 to 1951",
      },
      "Edward Frederick Lindley Wood, Viscount Halifax" => {
        link: "/government/history/past-foreign-secretaries/edward-wood",
        service: "1938 to 1940",
      },
      "Sir Samuel Hoare, Viscount Templewood" => {
        service: "1935",
      },
      "Sir John Simon, Viscount Simon" => {
        service: "1931 to 1935",
      },
      "Rufus Isaacs, Marquess of Reading" => {
        service: "1931",
      },
      "Arthur Henderson" => {
        service: "1929 to 1931",
      },
      "Sir Austen Chamberlain" => {
        link: "/government/history/past-foreign-secretaries/austen-chamberlain",
        service: "1924 to 1929",
      },
      "James Ramsay MacDonald" => {
        service: "1924",
      },
      "George Nathaniel Curzon, Marquess of Kedlesto" => {
        link: "/past-foreign-secretaries/george-curzon",
        service: "1919 to 1924",
      },
      "Arthur James Balfour, Earl of Balfour" => {
        service: "1916 to 1919",
      },
      "Sir Edward Grey, Viscount Grey of Fallodon" => {
        link: "/government/history/past-foreign-secretaries/edward-grey",
        service: "1905 to 1916",
      },
      "Henry Petty-Fitzmaurice, Marquess of Lansdowne" => {
        link: "/government/history/past-foreign-secretaries/henry-petty-fitzmaurice",
        service: "1900 to 1905",
      },
    }

    @nineteenth_century = {
      "Robert Cecil, Marquess of Salisbury" => {
        link: "/government/history/past-foreign-secretaries/robert-cecil",
        service: ["1895 to 1900", "1887 to 1892", "1885 to 1886", "1878 to 1880"],
      },
      "John Wodehouse, Earl of Kimberley" => {
        service: "1894 to 1895",
      },
      "Archibald Primrose, Earl of Rosebery" => {
        service: ["1892 to 1894", "1886"],
      },
      "Stafford Northcote, Earl of Iddesleigh" => {
        service: "1886 to 1887",
      },
      "George Leveson Gower, Earl Granville" => {
        link: "/government/history/past-foreign-secretaries/george-gower",
        service: ["1880 to 1885", "1870 to 1874", "1851 to 1852"],
      },
      "Lord Edward Stanley, Earl of Derby" => {
        service: ["1874 to 1878", "1866 to 1868"],
      },
      "George Villiers, Earl of Clarendon" => {
        service: ["1868 to 1870", "1865 to 1866", "1853 to 1858"],
      },
      "Lord John Russell, Earl Russell" => {
        service: ["1859 to 1865", "1852 to 1853"],
      },
      "James Harris, Earl of Malmesbury" => {
        service: ["1858 to 1859", "1852"],
      },
      "Henry John Temple, Viscount Palmerston" => {
        service: ["1846 to 1851", "1835 to 1841", "1830 to 1834"],
      },
      "George Hamilton Gordon, Earl of Aberdeen" => {
        link: "/government/history/past-foreign-secretaries/george-gordon",
        service: ["1841 to 1846", "1828 to 1830"],
      },
      "Arthur Wellesley, Duke of Wellington" => {
        service: "1834 to 1835",
      },
      "John William Ward, Viscount Dudley and Ward" => {
        service: "1827 to 1828",
      },
      "Robert Stewart, Viscount Castlereagh" => {
        service: "1812 to 1822",
      },
      "Richard Wellesley, Marquess Wellesley" => {
        service: "1809 to 1812",
      },
      "Henry Bathurst, Earl Bathurst" => {
        service: "1809",
      },
      "Charles Grey, Lord Howick" => {
        service: "1806 to 1807",
      },
      "Charles James Fox" => {
        link: "/government/history/past-foreign-secretaries/charles-fox",
        service: ["1806", "1783", "and 1783"],
      },
      "Henry Phipps, Lord Mulgrave" => {
        service: "1805 to 1806",
      },
      "Robert Banks Jenkinson, Lord Hawkesbury" => {
        service: "1804 to 1805",
      },
      "Dudley Ryder, Lord Harrowby" => {
        service: "1804",
      },
    }

    @eightteenth_century = {
      "William Wyndham Grenville, Lord Grenville" => {
        service: "1791 to 1801",
      },
      "Francis Godolphin Osborne, Marquess of Carmarthen" => {
        service: "1783 to 1791",
      },
      "George Nugent Temple Grenville, Earl Temple" => {
        service: "1783",
      },
      "Thomas Robinson, Lord Grantham" => {
        service: "1782 to 1783",
      },
    }

    @selection_of_profiles = {
      "Edward Frederick Lindley Wood, Viscount Halifax" => {
        href: "/government/history/past-foreign-secretaries/edward-wood",
        image_src: "history/past-foreign-secretaries/viscount-halifax.jpg",
        heading_text: "Edward Frederick Lindley Wood, Viscount Halifax",
        service: "1938 to 1940",
      },
      "Sir Austen Chamberlain" => {
        href: "/government/history/past-foreign-secretaries/austen-chamberlain",
        image_src: "history/past-foreign-secretaries/austen-chamberlain.jpg",
        heading_text: "Sir Austen Chamberlain",
        service: "1924 to 1929",
      },
      "George Nathaniel Curzon, Marquess of Kedleston" => {
        href: "/government/history/past-foreign-secretaries/george-curzon",
        image_src: "history/past-foreign-secretaries/george-nathaniel-curzon.jpg",
        heading_text: "George Nathaniel Curzon, Marquess of Kedleston",
        service: "1919 to 1924",
      },
      "Sir Edward Grey, Viscount Grey of Fallodon" => {
        href: "/government/history/past-foreign-secretaries/edward-grey",
        image_src: "history/past-foreign-secretaries/sir-edward-grey.jpg",
        heading_text: "Sir Edward Grey, Viscount Grey of Fallodon",
        service: "1905 to 1916",
      },
      "Henry Petty-Fitzmaurice, Marquess of Lansdowne" => {
        href: "/government/history/past-foreign-secretaries/henry-petty-fitzmaurice",
        image_src: "history/past-foreign-secretaries/lord-landsowne.jpg",
        heading_text: "Henry Petty-Fitzmaurice, Marquess of Lansdowne",
        service: "1900 to 1905",
      },
      "Robert Cecil, Marquess of Salisbury" => {
        href: "/government/history/past-foreign-secretaries/robert-cecil",
        image_src: "history/past-foreign-secretaries/marquess-of-salisbury.jpg",
        heading_text: "Robert Cecil, Marquess of Salisbury",
        service: ["1878 to 1880", "1885 to 1886", "1887 to 1892", "and 1895 to 1900"],
      },
      "George Leveson Gower, Earl Granville" => {
        href: "/government/history/past-foreign-secretaries/george-gower",
        image_src: "history/past-foreign-secretaries/earl-granville.jpg",
        heading_text: "George Leveson Gower, Earl Granville",
        service: ["1851 to 1852", "1870 to 1874", "and 1880 to 1885"],
      },
      "George Hamilton Gordon, Earl of Aberdeen" => {
        href: "/government/history/past-foreign-secretaries/george-gordon",
        image_src: "history/past-foreign-secretaries/lord-aberdeen.jpg",
        heading_text: "George Hamilton Gordon, Earl of Aberdeen",
        service: ["1828 to 1830", "and 1841 to 1846"],
      },
      "Charles James Fox" => {
        href: "/government/history/past-foreign-secretaries/charles-fox",
        image_src: "history/past-foreign-secretaries/charles-james-fox.jpg",
        heading_text: "Charles James Fox",
        service: ["1782", "1783", "and 1806"],
      },
      "William Wyndham Grenville, Lord Grenville" => {
        href: "/government/history/past-foreign-secretaries/william-grenville",
        image_src: "history/past-foreign-secretaries/lord-grenville.jpg",
        heading_text: "William Wyndham Grenville, Lord Grenville",
        service: "1791 to 1801",
      },
    }
  end

  def show
    if valid_names.include?(params[:id])
      render template: "past_foreign_secretaries/#{params[:id].underscore}"
    else
      render plain: "Not found", status: :not_found
    end
  end

private

  def valid_names
    %w[
      edward-wood
      austen-chamberlain
      george-curzon
      edward-grey
      henry-petty-fitzmaurice
      robert-cecil
      george-gower
      george-gordon
      charles-fox
      william-grenville
    ]
  end
end
