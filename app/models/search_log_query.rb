# En este modulo vamos agregando las queries
# tipo que hacemos
module SearchLogQuery
  # Solo construye el Hash usado para la query que saca los datos
  # del log de Amavis del tipo
  # ... Passed CLEAN {RelayedInbound}, ORIGINATING_POST [127.0.0.1]
  # <noresponder@caja18.cl> -> <ocerda@caja18.cl> ...
  def self.by_id(id = nil)
    { '_id' => id }
  end

  def self.by_messageid(id = nil)
    [{ 'component' => 'cleanup' },
     { 'messageid' => id }
    ]
  end

  def self.by_qid(qid = nil)
    { 'qid' => qid }
  end

  def self.amavisd_by_emails(from: nil, to: nil)
    ary = [{ 'tags' => 'amavis' }, { 'tags' => 'result' }]
    ary << domain_or_email('from', from)
    ary << domain_or_email('to', to)
    ary
  end

  def self.amavis_by_domains(from_domain: nil, to_domain: nil)
    [{ 'tags' => 'amavis' },
     { 'tags' => 'result' },
     { 'from_domain' => from_domain },
     { 'to_domain' => to_domain }
    ]
  end
  
  def self.domain_or_email(field, query)
    is_email?(query) ? { field => query} : { "#{field}_domain" => query }
  end
  
  def self.is_email?(string)
    !!(string =~ /\A\S+@.+\.\S+\z/)
  end

end
