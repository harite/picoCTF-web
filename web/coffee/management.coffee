TabbedArea = ReactBootstrap.TabbedArea
TabPane = ReactBootstrap.TabPane

ManagementTabbedArea = React.createClass
  getInitialState: ->
    tab = window.location.hash.substring(1)
    if tab == ""
      tab = "problems"

    bundles: []
    problems: []
    submissions: []
    tabKey: tab

  onProblemChange: ->
    apiCall "GET", "/api/admin/problems"
    .done ((api) ->
      @setState React.addons.update @state,
        problems: $set: api.data.problems
        bundles: $set: api.data.bundles
    ).bind this

    #This could take awhile. However, it may
    #introduce a minor race condition with
    #get_all_problems
    apiCall "GET", "/api/admin/problems/submissions"
    .done ((api) ->
      @setState React.addons.update @state,
        submissions: $set: api.data
    ).bind this


  componentDidMount: ->
    # Formatting hack
    $("#main-content>.container").addClass("container-fluid")
    $("#main-content>.container").removeClass("container")

    @onProblemChange()

  onTabSelect: (tab) ->
    @setState React.addons.update @state,
      tabKey:
        $set: tab

  render: ->
      <TabbedArea activeKey={@state.tabKey} onSelect={@onTabSelect}>
        <TabPane eventKey='problems' tab='Manage Problems'>
          <ProblemTab problems={@state.problems} onProblemChange={@onProblemChange}
            bundles={@state.bundles} submissions={@state.submissions}/>
        </TabPane>
        <TabPane eventKey='exceptions' tab='Exceptions'>
          <ExceptionTab/>
        </TabPane>
        <TabPane eventKey='shell-servers' tab='Shell Server'>
          <ShellServerTab/>
        </TabPane>
        <TabPane eventKey='configuration' tab='Configuration'>
          <SettingsTab/>
        </TabPane>
      </TabbedArea>

$ ->
  React.render <ManagementTabbedArea/>, document.getElementById("management-tabs")
