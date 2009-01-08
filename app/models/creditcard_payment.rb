class CreditcardPayment < Payment
  has_many :creditcard_txns
  belongs_to :creditcard
  
  alias :txns :creditcard_txns
  
  def find_authorization
    #find the transaction associated with the original authorization/capture 
    cc = order.creditcard_payment
    cc.txns.find(:first, 
                 :conditions => ["txn_type = ? or txn_type = ?", CreditcardTxn::TxnType::AUTHORIZE, CreditcardTxn::TxnType::CAPTURE],
                 :order => 'created_at DESC')
  end
end