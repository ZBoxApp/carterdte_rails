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

  def self.amavisd_by_emails(from: nil, to: nil)
    [{ 'tags' => 'amavis' },
     { 'tags' => 'result' },
     { 'from' => from },
     { 'to' => to }
    ]
  end

  def self.amavis_by_domains(from_domain: nil, to_domain: nil)
    [{ 'tags' => 'amavis' },
     { 'tags' => 'result' },
     { 'from_domain' => from_domain },
     { 'to_domain' => to_domain }
    ]
  end

end
