require 'spec_helper'

feature 'Project milestone', :feature do
  let(:user) { create(:user) }
  let(:project) { create(:empty_project, name: 'test', namespace: user.namespace) }
  let(:milestone) { create(:milestone, project: project) }

  before do
    login_as(user)
  end

  context 'milestone summary' do
    let(:project) { create(:empty_project, :public) }
    let(:milestone) { create(:milestone, project: project) }

    it 'shows the total weight when sum is greater than zero' do
      create(:issue, project: project, milestone: milestone, weight: 3)
      create(:issue, project: project,  milestone: milestone, weight: 1)

      visit milestone_path

      within '.milestone-summary' do
        expect(page).to have_content 'Total weight: 4'
      end
    end

    it 'hides the total weight when sum is equal to zero' do
      create(:issue, project: project, milestone: milestone, weight: nil)
      create(:issue, project: project,  milestone: milestone, weight: nil)

      visit milestone_path

      within '.milestone-summary' do
        expect(page).not_to have_content 'Total weight:'
      end
    end
  end

  context 'when project has enabled issues' do
    before do
      visit milestone_path
    end

    it 'shows issues tab' do
      within('#content-body') do
        expect(page).to have_link 'Issues', href: '#tab-issues'
        expect(page).to have_selector '.nav-links li.active', count: 1
        expect(find('.nav-links li.active')).to have_content 'Issues'
      end
    end

    it 'shows issues stats' do
      expect(page).to have_content 'issues:'
    end

    it 'shows Browse Issues button' do
      within('#content-body') do
        expect(page).to have_link 'Browse Issues'
      end
    end
  end

  context 'when project has disabled issues' do
    before do
      project.project_feature.update_attribute(:issues_access_level, ProjectFeature::DISABLED)
      visit milestone_path
    end

    it 'hides issues tab' do
      within('#content-body') do
        expect(page).not_to have_link 'Issues', href: '#tab-issues'
        expect(page).to have_selector '.nav-links li.active', count: 1
        expect(find('.nav-links li.active')).to have_content 'Merge Requests'
      end
    end

    it 'hides issues stats' do
      expect(page).to have_no_content 'issues:'
    end

    it 'hides Browse Issues button' do
      within('#content-body') do
        expect(page).not_to have_link 'Browse Issues'
      end
    end

    it 'does not show an informative message' do
      expect(page).not_to have_content('Assign some issues to this milestone.')
    end
  end

  def milestone_path
    visit namespace_project_milestone_path(project.namespace, project, milestone)
  end
end
