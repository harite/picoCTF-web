Label = ReactBootstrap.Label
Input = ReactBootstrap.Input
Button = ReactBootstrap.Button
ButtonToolbar = ReactBootstrap.ButtonToolbar
Grid = ReactBootstrap.Grid
Row = ReactBootstrap.Row
Col = ReactBootstrap.Col
Well = ReactBootstrap.Well
ListGroupItem = ReactBootstrap.ListGroupItem
ListGroup = ReactBootstrap.ListGroup
Accordion = ReactBootstrap.Accordion

ServerForm = React.createClass
  propTypes:
    new: React.PropTypes.bool.isRequired
    refresh: React.PropTypes.func.isRequired
    server: React.PropTypes.object

  getInitialState: ->
    if @props.new
      server = {"host":"", "port":"22", "username":"", "password":""}
    else
      server = @props.server

    {new: @props.new, shellServer: server}

  notifyAndRefresh: (data) ->
    apiNotify data
    @props.refresh()

  addServer: ->
    apiCall "POST", "/api/admin/shell_servers/add", @state.shellServer
    .done @notifyAndRefresh

  deleteServer: ->
    apiCall "POST", "/api/admin/shell_servers/remove", {"sid": @state.shellServer.sid}
    .done @notifyAndRefresh

  updateServer: ->
    apiCall "POST", "/api/admin/shell_servers/update", @state.shellServer
    .done @notifyAndRefresh

  loadProblems: ->
    apiCall "POST", "/api/admin/shell_servers/load_problems", {"sid": @state.shellServer.sid}
    .done @notifyAndRefresh

  checkStatus: ->
    apiCall "GET", "/api/admin/shell_servers/check_status", {"sid": @state.shellServer.sid}
    .done (data) ->
      apiNotify data

  updateHost: (e) ->
    copy = @state.shellServer
    copy.host = e.target.value
    @setState {shellServer: copy}

  updatePort: (e) ->
    copy = @state.shellServer
    copy.port = e.target.value
    @setState {shellServer: copy}

  updateUsername: (e) ->
    copy = @state.shellServer
    copy.username = e.target.value
    @setState {shellServer: copy}

  updatePassword: (e) ->
    copy = @state.shellServer
    copy.password = e.target.value
    @setState {shellServer: copy}

  createFormEntry: (name, type, value, onChange) ->
    <Row>
      <Col md={4}>
        <h4 className="pull-right">{name}</h4>
      </Col>
      <Col md={8}>
        <Input className="form-control" type={type} value={value} onChange={onChange} />
      </Col>
    </Row>

  render: ->
    if @state.new
      buttons =
        <ButtonToolbar className="pull-right">
          <Button onClick={@addServer}>Add</Button>
        </ButtonToolbar>
    else
      buttons =
        <ButtonToolbar className="pull-right">
          <Button onClick={@updateServer}>Update</Button>
          <Button onClick={@deleteServer}>Delete</Button>
          <Button onClick={@loadProblems}>Load Deployment</Button>
          <Button onClick={@checkStatus}>Check Status</Button>
        </ButtonToolbar>

    <div>
      {@createFormEntry "Host", "text", @state.shellServer.host, @updateHost}
      {@createFormEntry "Port", "text", @state.shellServer.port, @updatePort}
      {@createFormEntry "Username", "text", @state.shellServer.username, @updateUsername}
      {@createFormEntry "Password", "password", @state.shellServer.password, @updatePassword}
      {buttons}
    </div>

ShellServerList = React.createClass

  getInitialState: ->
    {shellServers: []}

  refresh: ->
    apiCall "GET", "/api/admin/shell_servers"
    .done ((api) ->
      @setState {shellServers: api.data}
    ).bind this

  componentDidMount: ->
    @refresh()

  createShellServerForm: (server, i) ->
    if server == null
      shellServer = <ServerForm new={true} key={i+"new"} refresh={@refresh}/>
      header = <div> New Shell Server </div>
    else
      shellServer = <ServerForm new={false} server={server} key={server.sid} refresh={@refresh}/>
      header = <div> {server.host} </div>

    <Panel bsStyle={"default"} eventKey={i} key={i} header={header}>
      {shellServer}
    </Panel>

  render: ->
    serverList = _.map @state.shellServers, @createShellServerForm
    serverList.push(@createShellServerForm(null, @state.shellServers.length))

    <Accordion defaultActiveKey={0}>
      {serverList}
    </Accordion>

ProblemLoaderTab = React.createClass
  getInitialState: ->
    {publishedJSON: ""}

  handleChange: (e) ->
    @setState {publishedJSON: e.target.value}

  pushData: ->
    apiCall "POST", "/api/problems/load_problems", {competition_data: @state.publishedJSON}
    .done ((data) ->
      apiNotify data
      @clearPublishedJSON()
    ).bind this

  clearPublishedJSON: ->
    @setState {publishedJSON: ""}

  render: ->
    publishArea =
    <div className="form-group">
      <h4>Paste your published JSON here:</h4>
      <Input className="form-control" type='textarea' rows="10"
        value={@state.publishedJSON} onChange={@handleChange}/>
    </div>

    <div>
      <Row>{publishArea}</Row>
      <Row>
        <ButtonToolbar>
          <Button onClick={@pushData}>Submit</Button>
          <Button onClick={@clearPublishedJSON}>Clear Data</Button>
        </ButtonToolbar>
      </Row>
    </div>


ShellServerTab = React.createClass

  render: ->
    <Well>
      <Grid>
        <Row>
          <h4>To add problems, either enter your shell server information on the left or paste your published JSON on the right.</h4>
        </Row>
        <Row>
          <Col md={6}>
            <ShellServerList />
          </Col>
          <Col md={6} className="pull-right">
            <ProblemLoaderTab/>
          </Col>
        </Row>
      </Grid>
    </Well>
