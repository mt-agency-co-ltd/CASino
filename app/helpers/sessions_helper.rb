module SessionsHelper
  def acquire_login_ticket
    ticket = LoginTicket.create ticket: random_ticket_string('LT')
    logger.debug "Created login ticket '#{ticket.ticket}'"
    ticket
  end

  def current_ticket_granting_ticket
    if @current_ticket_granting_ticket
      @current_ticket_granting_ticket
    else
      ticket_granting_ticket = TicketGrantingTicket.where(ticket: cookies[:tgt]).first unless cookies[:tgt].nil?
      unless ticket_granting_ticket.nil?
        if same_browser?(ticket_granting_ticket.user_agent, request.env['HTTP_USER_AGENT'])
          ticket_granting_ticket.user_agent = request.env['HTTP_USER_AGENT']
          ticket_granting_ticket.save
          @current_ticket_granting_ticket = ticket_granting_ticket
        end
      end
    end
  end

  def current_ticket_granting_ticket?(ticket_granting_ticket)
    current_ticket_granting_ticket == ticket_granting_ticket
  end

  def signed_in?
    !current_ticket_granting_ticket.nil?
  end
end
