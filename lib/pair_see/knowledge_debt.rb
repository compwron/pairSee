module PairSee
  class KnowledgeDebt
    def initialize(log_lines, card_prefixes, people)
      @log_lines = log_lines
      @card_prefixes = card_prefixes
      @people = people
    end

    def knowledge_debt
      #   cards - > commits -> people on commits -> early elimination of mult. names for now (later, %)
      card_to_commits = {}

      @log_lines.each {|ll|
        cn = ll.card_number(@card_prefixes)
        if !card_to_commits[cn]
          card_to_commits[cn] = []
        end
        card_to_commits[cn] << ll
      }

      c2c = card_to_commits.reject {|k, v| v.count == 0}


      c2c.map {|card_name, commits|
        has_debt = commits.map {|c|
          @people.select {|person| c.authored_by?(person)}.count > 1
        }.all?
        [commits.count, card_name, has_debt]
      }.reject {|_, _, has_debt| !has_debt
      }.sort {|a| a.first
      }.map {|a|
        count = a[0]
        card_name = a[1]
        has_debt = a[2]
        "#{card_name} has #{count} commits with only one committer"}
    end
  end
end
